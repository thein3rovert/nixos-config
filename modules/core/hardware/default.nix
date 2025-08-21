{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.coreModules.hardware;
in
{
  options.coreModules.hardware.enable = lib.mkEnableOption "Enable my core hardware modules";

  # Can this config be any variable
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      # hardware.opengl has been renamed tp hardware.graphic
      enable = true;
    };

    hardware.enableAllFirmware = true;
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerksdbfOnBoot = true;
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

}
