{
  config,
  lib,
  ...
}:
{
  options.hardwareSetup.profiles.laptop.enable = lib.mkEnableOption "Laptop hardware configuration.";

  /*
    INFO: Profile config for default, intel and nvidia.
    For now i am fine with intel because i dont have nvidia
  */

  config = lib.mkMerge [
    (lib.mkIf config.hardwareSetup.profiles.laptop.enable {
      services = {
        tuned.enabled = lib.mkDefault true;
        upower.enable = true;
      };
    })
    (lib.mkIf
      ((lib.elem "kvm-intel" config.boot.kernelModules) && config.myHardware.profiles.laptop.enable)
      {
        # powerManagement.powertop.enable = true;
        services.thermald.enable = true;
      }
    )
  ];
}
