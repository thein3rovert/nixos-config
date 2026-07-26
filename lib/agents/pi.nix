# ── renderForPi ───────────────────────────────────────────────
#
# WHAT IT DOES
# ------------
# Turns canonical agent definitions into the file layout the Pi harness
# expects:
#   AGENTS.md          — primary agent description + specialist listing
#                        (+ optional coding-rules section)
#   SYSTEM.md          — primary agent's systemPrompt (replaces Pi default)
#   agents/<slug>.md   — one per agent using pi-subagents frontmatter
#
# Pi-specific frontmatter fields (in agents/*.md):
#   name, description, tools, extensions, model, thinking, skill,
#   output, defaultReads, defaultProgress, interactive, maxSubagentDepth
# This renderer currently populates: name, description, tools, model, skill.
#
# PERMISSION MAPPING (canonical → Pi)
# Pi has no per-pattern granularity and no "ask" intent — only per-tool
# include/exclude. So:
#   intent = "allow" OR "ask" → tool INCLUDED (we lose the ask semantics)
#   intent = "deny"           → tool EXCLUDED
# When specific allow rules exist, tool is always included (since Pi can't
# restrict by pattern, we err on the side of inclusion).
#
# ARGS
#   pkgs             nixpkgs set (writeText/runCommand)
#   canonical         attrset of agents keyed by slug
#   modelOverrides   optional { <slug> = "<provider/model>"; }
#   primaryAgent     optional slug to force as primary
#                    (default: the agent with mode = "primary")
#   codingRules      optional attrset { agents, languages, concerns, frameworks }
#                    passed to ../coding-rules.nix to append a rules section
#                    to AGENTS.md
#
# RETURNS
#   A store path (runCommand) containing AGENTS.md, SYSTEM.md, agents/*.md.
#
# THROWS
#   if no agent has mode = "primary" and primaryAgent was not provided.
#
# CONSUMES (from helpers.nix)
#   renderAgentFiles — linkFarm primitive that writes agents/*.md
# CONSUMES (sibling file)
#   ../coding-rules.nix — imported lazily, only when codingRules != null
{ lib, helpers }:

{
  pkgs,
  canonical,
  modelOverrides ? { },
  primaryAgent ? null,
  codingRules ? null,
}:

let
  inherit (helpers) renderAgentFiles;

  # Import coding-rules lib lazily — only fails at build time if
  # codingRules is non-null AND the file is missing.
  codingRulesLib = import ../coding-rules.nix { inherit lib; };

  # ── Find the primary agent (there should be exactly one) ─────
  primaryAgents = lib.filterAttrs (_: a: a.mode == "primary") canonical;
  primaryNames = lib.attrNames primaryAgents;
  primaryName =
    if primaryAgent != null then
      primaryAgent
    else if primaryNames == [ ] then
      throw "lib.agents.renderForPi: no primary agent found"
    else
      builtins.head primaryNames;
  primary = builtins.getAttr primaryName primaryAgents;

  # Subagents for the specialist listing in AGENTS.md.
  subagents = lib.filterAttrs (_: a: a.mode != "primary") canonical;

  # ── piToolsForAgent ─────────────────────────────────────────
  # Translate canonical permission intents → Pi's per-tool include list.
  #
  # Mapping table:
  #   canonical   →  Pi tool
  #   bash        →  "bash"
  #   edit        →  "edit"
  #   webfetch    →  "fetch_content"
  #   websearch   →  "web_search"
  #
  # `read`, `grep`, `find`, `ls` are ALWAYS included (no permission concept
  # in Pi).
  piToolsForAgent =
    agent:
    let
      perms = agent.permissions or { };
      tools = [ ];
      # Always available: read (no permission concept in Pi)
      addIf =
        tool: section: if section.intent == "allow" || section.intent == "ask" then [ tool ] else [ ];
      withBash = tools ++ (addIf "bash" (perms.bash or { intent = "ask"; }));
      withEdit = withBash ++ (addIf "edit" (perms.edit or { intent = "deny"; }));
      withFetch = withEdit ++ (addIf "fetch_content" (perms.webfetch or { intent = "deny"; }));
      withSearch = withFetch ++ (addIf "web_search" (perms.websearch or { intent = "deny"; }));
    in
    lib.unique (
      withSearch
      ++ [ "read" "grep" "find" "ls" ]
    );

  # ── mkPiFrontmatter ─────────────────────────────────────────
  # Build YAML frontmatter for pi-subagents .md files.
  #
  # Produces:
  #   ---
  #   name: <slug>
  #   description: "..."
  #   tools: read, grep, find, ls, bash, edit
  #   model: <override>      # optional
  #   skill: <skills>        # optional, comma-separated
  #   ---
  mkPiFrontmatter =
    name: agent:
    let
      tools = piToolsForAgent agent;
      descLine = "description: \"${agent.description}\"";
      toolsLine = "tools: ${lib.concatStringsSep ", " tools}";
      model = if modelOverrides ? ${name} then "model: ${modelOverrides.${name}}" else "";
      skillsLine =
        if (agent ? skills) && agent.skills != [ ] then
          "skill: ${lib.concatStringsSep ", " agent.skills}"
        else
          "";
    in
    "---\n"
    + "name: ${name}\n"
    + "${descLine}\n"
    + "${toolsLine}\n"
    + (lib.optionalString (model != "") "${model}\n")
    + (lib.optionalString (skillsLine != "") "${skillsLine}\n")
    + "---\n";

  mkPiAgentContent = name: agent: (mkPiFrontmatter name agent) + agent.systemPrompt;

  piAgentFiles = renderAgentFiles pkgs canonical mkPiAgentContent "pi-agent-files";

  # ── Build AGENTS.md content ────────────────────────────────
  # Top-level markdown file with:
  #   # Agent Instructions
  #   ## <primary display_name>
  #   <primary.description>
  #   ## Available Specialists
  #   - **<display_name>**: <description>
  #   ...
  #   < optional coding-rules markdown section >
  primaryDn = primary.display_name or primaryName;
  specialistEntries =
    let
      mkEntry =
        name: agent:
        let
          dn = agent.display_name or name;
        in
        "- **" + dn + "**: " + agent.description;
    in
    lib.mapAttrsToList mkEntry subagents;

  # ── Coding rules section (optional) ────────────────────────
  # When codingRules is provided, append selected rules to AGENTS.md.
  # codingRules attrset: { agents, languages, concerns, frameworks }
  codingRulesSection =
    if codingRules != null then
      let
        section = codingRulesLib.mkRulesMdSection codingRules;
      in
      if section != "" then "\n" + section else ""
    else
      "";

  agentsMd =
    "# Agent Instructions\n"
    + "\n"
    + "## "
    + primaryDn
    + "\n"
    + "\n"
    + primary.description
    + "\n"
    + "\n"
    + (
      if subagents == { } then
        ""
      else
        "## Available Specialists\n\n" + lib.concatStringsSep "\n" specialistEntries + "\n"
    )
    + codingRulesSection;

  agentsMdFile = pkgs.writeText "AGENTS.md" agentsMd;
  systemMdFile = pkgs.writeText "SYSTEM.md" primary.systemPrompt;
in
pkgs.runCommand "pi-agents" { } ''
  mkdir -p $out/agents
  cp ${agentsMdFile} $out/AGENTS.md
  cp ${systemMdFile} $out/SYSTEM.md
  cp -r ${piAgentFiles}/* $out/agents/
''