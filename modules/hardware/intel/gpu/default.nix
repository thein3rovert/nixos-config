{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.hardwareSetup.intel.gpu.enable = lib.mkEnableOption "Intel GPU configuration";
  config = lib.mkIf config.hardwareSetup.intel.gpu.enable {
    boot.initrd.kernelModules = [ "i915" ];

    environment.sessionVariables = {

      LIBVA_DRIVER_NAME = "iHD";
      VDPAU_DRIVER = "va_gl";
    };

    hardware = {
      intel-gpu-tools.enable = true;

      graphics = {
        enable = true;

        extraPackages = with pkgs; [
          intel-media-driver
          (intel-vaapi-driver.override { enableHybridCodec = true; })
          libvdpau-va-gl

          # Core Intel driver
          libva
          libva-utils

          # Native Intel drivers best for GPUs
          # vaapiIntel # Not sure if valid
          # vaapiVdpau
          libva-vdpau-driver
        ];

        extraPackages32 = with pkgs; [
          driversi686Linux.intel-media-driver
          (driversi686Linux.intel-vaapi-driver.override { enableHybridCodec = true; })
          driversi686Linux.libvdpau-va-gl
        ];
      };
    };

    # Use generic driver built into Xorg
    services.xserver.videoDrivers = [ "modesetting" ];
  };
}
