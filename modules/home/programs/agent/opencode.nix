{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.programs.agent.opencode =
    let
      shared = import ./shared/common.nix { inherit lib; };
    in
    with lib;
    {
      enable = mkEnableOption "Opencode agent management using canonical agent.toml definitions";
      agentsInput = shared.mkAgentsInputOption ''
        The `agents` flake input (my personal AGENTS repo (Polis)).
        When set, agents are rendered from canonical agent.toml files
        and symlinked to opencode default config ~/.config/opencode/agents/.
      '';

      modelOverrides = shared.mkModelOverridesOption;
    };

  config =
    with lib;
    let
      cfg = config.homeSetup.programs.agent.opencode;
      shared = import ./shared/common.nix { inherit lib; };
    in
    mkIf cfg.enable {
      # Render agent files and symlinked to opencode config in .config
      xdg.configFile."opencode/agents" =
        let
          allAgentLib = (import ../../../../lib { inherit lib; }).agents;
        in
        mkIf (cfg.agentsInput != null) {
          source = allAgentLib.renderForOpencode {
            inherit pkgs;
            canonical = allAgentLib.loadAgents {
              agentsDir = "${cfg.agentsInput}/agents-nix";
            };
            modelOverrides = cfg.modelOverrides;
          };
        };

      # Static config dirs from POLIS ( Shared Agent repo )
      xdg.configFile."opencode/context" = mkIf (cfg.agentsInput != null) {
        source = cfg.agentsInput + "/context";
      };
      xdg.configFile."opencode/commands" = mkIf (cfg.agentsInput != null) {
        source = cfg.agentsInput + "/commands";
      };
      xdg.configFile."opencode/prompts" = mkIf (cfg.agentsInput != null) {
        source = cfg.agentsInput + "/prompts";
      };
      xdg.configFile."opencode/skills" = mkIf (cfg.agentsInput != null) {
        source = cfg.agentsInput + "/skills";
      };
    };

}
