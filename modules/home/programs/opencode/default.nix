{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.coding.opencode;
in
{
  options.coding.opencode = {
    enable = mkEnableOption "Opencode AI coding Harness";

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Extra opencode settings, we merge it by using the 
        mkMerge into the programs.opencode.settings. Use this
        to add provider configuration that is specific to a 
        machine or organisation.
      '';
    };

  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = mkMerge [
        {
          theme = "onedark";
          formatter = {
            alejandra = {
              command = [
                "alejandra"
                "-q"
                "-"
              ];
              extensions = [ ".nix" ];
            };
          };
        }
        cfg.extraSettings # For other external or custom settings
      ];
    };
  };
}
