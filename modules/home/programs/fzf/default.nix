{
  config,
  lib,
  ...
}:
{
  options.homeSetup.programs.fzf.enable = lib.mkEnableOption "Eza systtem config";

  config = lib.mkIf config.homeSetup.programs.fzf.enable {

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
