{
  pkgs,
  config,
  lib,
  ...
}:

{
  hardware.graphics = {
    # hardware.opengl has been renamed tp hardware.graphic
    enable = true;
  };

  hardware.enableAllFirmware = true; # Not in main config
  # hardware.pulseaudio.enable = false; Moved to services
  hardware.bluetooth.enable = true; # enables support for Bluetooth   # Not in main config
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

}