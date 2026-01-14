{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.hardwareSetup.intel.gpu = {
    enable = lib.mkEnableOption "Intel GPU configuration";

    driver = lib.mkOption {
      description = "INtel GPU driver to use";

      type = lib.types.enum [
        "i915"
        "xe"
      ];
      default = "i915";
    };
  };

  config = lib.mkIf config.hardwareSetup.intel.gpu.enable {
    boot.initrd.kernelModules = [ config.hardwareSetup.intel.gpu.driver ];

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

          intel-ocl
          vpl-gpu-rt
          intel-compute-runtime

          # Core Intel driver
          # libva
          # libva-utils

          # Native Intel drivers best for GPUs
          # libva-vdpau-driver
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
