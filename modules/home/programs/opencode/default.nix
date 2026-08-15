{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.homeSetup.programs.opencode;
in
{
  options.homeSetup.programs.opencode = {
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
      example = literalExpression ''
        {
        provider.opencode-go = {
          name = "opencode-go";
          models."deepseek-v4" = { limit.context = 200000; };
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = mkMerge [
        {
          theme = "kanagawa";
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
