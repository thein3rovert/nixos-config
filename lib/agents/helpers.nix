# Shared helpers used by every renderer (opencode.nix, pi.nix, later: claude-code.nix).
#
# Imported as:
#   helpers = import ./agents/helpers.nix { inherit lib; };
#   inherit (helpers) parseRule renderAgentFiles;
{ lib }:

let
  # ── parseRule ─────────────────────────────────────────────────
  # Split a rule string on the LAST colon to get { pattern, action }.
  #
  # Why split on the LAST colon: patterns themselves can contain colons
  # (URLs, paths), so we split on the rightmost one and rejoin the LHS.
  #
  # Examples:
  #   "rm -rf *:ask"           → { pattern = "rm -rf *";      action = "ask";   }
  #   "/run/agenix/**:deny"     → { pattern = "/run/agenix/**"; action = "deny";  }
  #   "git push origin:allow"  → { pattern = "git push origin"; action = "allow"; }
  parseRule =
    ruleStr:
    let
      parts = lib.strings.splitString ":" ruleStr;
      action = lib.last parts;
      pattern = lib.concatStringsSep ":" (lib.init parts);
    in
    { inherit pattern action; };

  # ── renderAgentFiles ─────────────────────────────────────────
  # Render canonical agent definitions into a directory of *.md files
  # via a linkFarm (cheap, symlink-only output).
  #
  # Each agent gets a "<slug>.md" file whose content is `mkContent slug agent`.
  #
  # Args:
  #   pkgs        — nixpkgs set (provides linkFarm + writeText)
  #   canonical   — attrset of agent definitions keyed by slug
  #   mkContent   — function: slug -> agent -> string (file body)
  #   name        — derivation name (e.g. "opencode-agents")
  #
  # Returns:
  #   A store path: /nix/store/xxx-<name>/ containing one .md per agent.
  #
  # Example:
  #   canonical = { chiron = {...}; explore = {...}; }
  #   mkContent = name: agent: "---\n...\n---\n" + agent.systemPrompt
  #   → /nix/store/xxx-opencode-agents/
  #       chiron.md
  #       explore.md
  renderAgentFiles =
    pkgs: canonical: mkContent: name:
    pkgs.linkFarm name (
      lib.mapAttrsToList (n: a: {
        name = "${n}.md";
        path = pkgs.writeText "${n}.md" (mkContent n a);
      }) canonical
    );
in
{ inherit parseRule renderAgentFiles; }