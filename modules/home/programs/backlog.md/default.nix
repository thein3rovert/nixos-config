{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.homeSetup.programs.backlog-md.enable = lib.mkEnableOption "Backlog.md task manager";

  config = lib.mkIf config.homeSetup.programs.backlog-md.enable {
    home.packages = [ inputs.backlog-md.packages.${pkgs.system}.default ];
  };
}
