# ── renderForOpencode ─────────────────────────────────────────
#
# WHAT IT DOES
# ------------
# Turns canonical agent definitions into a directory of <slug>.md files
# that OpenCode can drop straight into ~/.config/opencode/agents/ (or
# .opencode/agents/ for project-level).
#
# Each file = YAML frontmatter + the agent's systemPrompt body.
#
# EXAMPLE (canonical input → produced file)
#
#   Given canonical = {
#     chiron = {
#       description = "Primary work agent";
#       mode        = "primary";
#       systemPrompt = "You are Chiron...";
#       permissions = {
#         bash = { intent = "ask";  rules = [ "git status*:allow"  "rm *:deny" ]; };
#         edit = { intent = "allow"; };
#       };
#     };
#   }
#   and modelOverrides = { chiron = "anthropic/claude-sonnet-4"; }
#
#   → produces chiron.md :
#
#     ---
#     description: "Primary work agent."
#     mode: primary
#     model: anthropic/claude-sonnet-4
#     permission:
#       bash:
#         "*": ask
#         "git status*": allow
#         "rm *": deny
#       edit: allow
#     ---
#     You are Chiron...
#
# ARGS
#   pkgs            nixpkgs set (provides linkFarm/writeText)
#   canonical       attrset of agents keyed by slug (from loadCanonical)
#   modelOverrides  optional { <slug> = "<provider/model>"; } — omitted
#                   frontmatter `model:` line if slug not in this map
#
# RETURNS
#   A store path (linkFarm) containing one <slug>.md per agent.
#
# CONSUMES (from helpers.nix)
#   parseRule        — splits "pattern:action" rule strings
#   renderAgentFiles — linkFarm primitive that writes the .md files
{ lib, helpers }:

{ pkgs, canonical, modelOverrides ? { } }:

let
  inherit (helpers) parseRule renderAgentFiles;

  # ── renderPermSection ───────────────────────────────────────
  # Turns ONE permission section (e.g. `bash` or `edit`) into a list
  # of YAML lines. Two shapes:
  #
  #   1) intent-only (no `rules` or `rules = []`)
  #      → returns a single flat line:  "  <tool>: <intent>"
  #
  #   2) intent + rules
  #      → returns a nested block:
  #          "  <tool>:"           <- starts the block
  #          "    \"*\": <intent>"  <- wildcard catch-all (section.intent)
  #          "    \"<pattern>\": <action>"  <- one per rule
  #
  # EXAMPLE
  #   section = {
  #     intent = "ask";
  #     rules  = [ "git status*:allow"  "rm *:deny" ];
  #   }
  #   → [ "  bash:"
  #       "    \"*\": ask"
  #       "    \"git status*\": allow"
  #       "    \"rm *\": deny"
  #     ]
  renderPermSection =
    tool: section:
    if !(section ? rules) || section.rules == [ ] then
      # Shape 1 — simple intent, no per-pattern rules
      [ "  ${tool}: ${section.intent}" ]
    else
      # Shape 2 — intent + rules block
      let
        parsedRules = map parseRule section.rules;           # ["git status*:allow"] → [{pattern="git status*"; action="allow";}]
        wildcardLine = "    \"*\": ${section.intent}";        # the section's default intent
        ruleLines = map (r: "    \"${r.pattern}\": ${r.action}") parsedRules;
      in
      [ "  ${tool}:" ] ++ [ wildcardLine ] ++ ruleLines;

  # ── renderPermBlock ─────────────────────────────────────────
  # Turns the WHOLE permissions attrset into YAML lines (or [] when
  # empty / null so we can skip adding a permission: block later).
  #
  # EXAMPLE
  #   permissions = {
  #     bash = { intent = "ask"; rules = [ "rm *:deny" ]; };
  #     edit = { intent = "allow"; };
  #   }
  #   → [ "permission:"
  #       "  bash:"
  #       "    \"*\": ask"
  #       "    \"rm *\": deny"
  #       "  edit: allow"
  #     ]
  renderPermBlock =
    permissions:
    if permissions == { } || permissions == null then
      [ ]
    else
      [ "permission:" ] ++ lib.concatLists (lib.mapAttrsToList renderPermSection permissions);

  # ── mkFrontmatter ───────────────────────────────────────────
  # Assembles the YAML frontmatter for ONE agent .md file.
  #
  # Lines produced:
  #   ---
  #   description: "<agent.description>."       ← always present
  #   mode: <agent.mode>                        ← always present
  #   model: <value>                            ← only if modelOverrides.<name> is set
  #   <permLines>                               ← only if agent has permissions
  #   ---
  #
  # EXAMPLE (see the header example above — produces that frontmatter)
  mkFrontmatter =
    name: agent:
    let
      descLine = "description: \"${agent.description}.\"";
      modeLine = "mode: ${agent.mode}";
      # `lib.optionalString cond str` returns "" when cond is false — so the line
      # is silently omitted when no modelOverride is set for this agent.
      modelLine = lib.optionalString (modelOverrides ? ${name}) "model: ${modelOverrides.${name}}\n";
      permBlock = renderPermBlock (agent.permissions or { });
      # Empty permission block → no `permission:` lines in the frontmatter.
      permLines = if permBlock == [ ] then "" else lib.concatStringsSep "\n" permBlock + "\n";
    in
    "---\n${descLine}\n${modeLine}\n${modelLine}${permLines}---\n";

  # ── mkAgentContent ──────────────────────────────────────────
  # Stitches frontmatter + systemPrompt into the final file body.
  #
  #   mkFrontmatter "chiron" agent = "---\n...\n---\n"
  #   agent.systemPrompt            = "You are Chiron..."
  #   → "---\n...\n---\nYou are Chiron..."
  mkAgentContent = name: agent: (mkFrontmatter name agent) + agent.systemPrompt;
in
# Hand off to the shared primitive — produces a linkFarm directory:
#   /nix/store/xxx-opencode-agents/
#     chiron.md
#     explore.md
#     ...
# Each file = mkAgentContent applied to that agent.
renderAgentFiles pkgs canonical mkAgentContent "opencode-agents"