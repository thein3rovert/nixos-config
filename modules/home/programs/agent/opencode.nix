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
}
