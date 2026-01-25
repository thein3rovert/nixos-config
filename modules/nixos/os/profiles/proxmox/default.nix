{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    ;
  If = mkIf;
  setDefault = mkDefault;
  createEnableOption = mkEnableOption;
  cfg = config.nixosSetup.profiles.proxmox;
in
{
  options.nixosSetup.profiles.proxmox.enable = createEnableOption "Proxmox credentials";
  config = If cfg.enable {

  };
}
