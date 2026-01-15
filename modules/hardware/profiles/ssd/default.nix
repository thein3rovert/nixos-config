{
  config,
  lib,
  ...
}:
{
  options.hardwareSetup.profiles.ssd.enable = lib.mkEnableOption "SSD support";

  config = lib.mkIf config.hardwareSetup.profiles.ssd.enable {
    services.fstrim.enable = true;
  };
}
