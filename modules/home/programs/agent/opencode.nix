{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./shared/common.nix
  ];

  options.ai.agents.opencode =
    let
      shared = ./shared/common.nix { inherit lib; };
    in

    with lib;
    {
      enable = mkEnableOption "Opencode agent management using canonical agent.toml definitions";
      agentsInput = shared.mkAgentsInputOption ''
        The `agents` flake input (my personal AGENTS repo (Polis)).
        When set, agents are rendered from cononical agent.toml files
        and symliked to opencode default config ~/.config/opencode/agents/.
      '';

      modelOverrides = shared.mkModelOverridesOption;
    };

  config =
    with lib;
    # let
    #
    #   shared = ./shared/common.nix { inherit lib; };
    #   cfg = config.ai.agents.opencode;
    # in

    mkIf cfg.enable {
      # Render agent files and symlinked to opencode config in .config
      xdg.configFile."opencode/agents" =
        let
          allAgentLib = (import ../../../../lib { inherit lib; }).agents;
        in
        mkIf (cfg.agentsInput != null) {
          source = allAgentLib.renderForOpencode {
            inherit pkgs;
            # INFO: Still dont know what load agent is yet
            canonical = cfg.agentsInput.lib.loadAgents;
            modelOverrides = cfg.modelOverrides;
          };
        };

      # Static config dirs from POLIS ( Shared Agent repo )
      xdg.configFile."opencode/context" = mkIf (cfg.agentsInput != null) {
        sources = "${cfg.agentsInput}/context";
      };
      xdg.configFile."opencode/commands" = mkIf (cfg.agentsInput != null) {
        source = "${cfg.agentsInput}/commands";
      };
      xdg.configFile."opencode/prompts" = mkIf (cfg.agentsInput != null) {
        source = "${cfg.agentsInput}/prompts";
      };
    };

}
