{
  config,
  lib,
  ...
}:
{
  options.hardwareSetup.intel.cpu.enable = lib.mkEnableOption "Config for intel CPU";

  config = lib.mkIf config.hardwareSetup.intel.cpu.enable {
    boot.kernelModules = [ "kvm-intel" ];

    # Low lovel firmware that runs inside the CPU
    # helps to control internal logic
    hardware.cpu.intel.updateMicrocode = true;
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
