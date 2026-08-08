# Per-tool agent sub-modules
# Each module handles rendering canonical agent.toml definitions
# for a specific AI coding tool.
#
# Also provides the shared agent.skills submodule that writes
# ~/.agents/skills — the central skills directory used by Pi, OpenCode, etc.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  shared = import ./shared/common.nix { inherit lib; };
  cfg = config.homeSetup.programs.agent;
  mkIf = lib.mkIf;
in
{
  imports = [
    ./opencode.nix
  ];

  options.homeSetup.programs.agent = {
    enable = lib.mkEnableOption "AI agent configuration (opencode, pi, shared skills)";
    
    agentsInput = shared.mkAgentsInputOption ''
      The `agents` flake input (my personal AGENTS repo (Polis)).
      When set, agents are rendered from canonical agent.toml files
      and deployed to respective locations.
    '';
    
    agentSkills = shared.agentExternalSkillOption;
  };

  config = mkIf (cfg.enable && cfg.agentsInput != null) {
    # Deploy shared skills to ~/.agents/skills for Pi, ClaudeCode, etc.
    home.file.".agents/skills".source = cfg.agentsInput.lib.mkSkills {
      inherit pkgs;
      customSkills = "${cfg.agentsInput}/skills";
      # In case we want to provide additional skills in a dedicated folder
      externalSkills = shared.mapExternalSkills cfg.agentSkills;
    };
  };
}
