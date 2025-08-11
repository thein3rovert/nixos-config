{
  config,
  lib,
  ...
}:
{
  options.homeSetup.programs.eza.enable = lib.mkEnableOption "Eza systtem config";

  config = lib.mkIf config.homeSetup.programs.eza.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      extraOptions = [
        "-l"
        "--icons"
        "--git"
        "-a"
      ];
    };
  };
}
