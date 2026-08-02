# Per-tool agent sub-modules
# Each module handles rendering canonical agent.toml definitions
# for a specific AI coding tool.
#
# Also provides the shared coding.agents.skills submodule that writes
# ~/.agents/skills — the central skills directory used by Pi, OpenCode, etc.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  shared = import ./shared/common.nix { inherit lib; };
  cfg = config.ai.agents.skills;
  mkIf = lib.mkIf;
in
{
  imports = [
    ./opencode.nix
  ];

  options.ai.agents.skills = {
    agentsInput = shared.mkAgentsInputOption ''
      The `agents` flake input (my personal AGENTS repo (Polis)).
      When set, agents are rendered from cononical agent.toml files
      and symliked to opencode default config ~/.config/opencode/agents/.
    '';
    agentSkills = shared.agentExternalSkillOption;
  };

  config = mkIf (cfg.agentsInput != null) {
    home.file.".agents/skills".source = cfg.agentsInput.lib.mkSkills {
      inherit pkgs;
      customSkills = "${cfg.agentsInput}/skills";
      externalSkills = shared.mapExternalSkills cfg.agentSkills;
    };
  };
}
