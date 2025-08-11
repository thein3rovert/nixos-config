{
  config,
  lib,
  ...
}:
{
  options.homeSetup.programs.direnv.enable = lib.mkEnableOption "Eza systtem config";

  config = lib.mkIf config.homeSetup.programs.direnv.enable {
    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
