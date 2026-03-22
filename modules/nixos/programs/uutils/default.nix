{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.nixosSetup.programs.uutils.enable = lib.mkEnableOption "rust uutils coreutils replacement";

  config = lib.mkIf config.nixosSetup.programs.uutils.enable {
    environment.systemPackages = with pkgs; [
      (lib.hiPrio uutils-coreutils-noprefix)
      (lib.hiPrio uutils-diffutils)
      (lib.hiPrio uutils-findutils)
    ];
  };
}
