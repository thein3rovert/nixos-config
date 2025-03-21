{ pkgs, config, ... }: # Function arguments: pkgs, config, and any other arguments

{
  # Bootloader configuration
  boot.loader.efi.canTouchEfiVariables = true; # Allow the bootloader to modify EFI variables
  boot.loader.grub.enable = true; # Enable GRUB bootloader
  boot.loader.grub.devices = [ "nodev" ]; # Specify devices for GRUB installation (nodev means no specific device)
  boot.loader.grub.efiSupport = true; # Enable EFI support for GRUB
  boot.loader.grub.useOSProber = true; # Use OS prober to detect other operating systems

  # Kernel parameters
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # Set the maximum number of memory map areas a process may have
  };

  # Temporary filesystem (tmpfs) configuration
  boot.tmp.useTmpfs = true; # Use tmpfs for /tmp directory
  boot.tmp.tmpfsSize = "10G"; # Set the size of tmpfs to 4GB
  # boot.tmpfsSize = "4G";  # Alternative way to set tmpfs size (commented out)

  # Kernel modules to load at boot
  boot.kernelModules = [ "i2c-dev" ]; # Load i2c-dev module for I2C device support
  boot.blacklistedKernelModules = [ "rtw88" ];

    ## For updating my driver
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtw88 ];
  # Disable power managemnet
  boot.kernelParams = [
    "rtw_8821ce.disable_msi=1"
    "rtw_8821ce.disable_aspm=1"
  ];

  # OBS Virtual Cam Support - v4l2loopback setup
  # boot.kernelModules = [ "v4l2loopback" ];  # Load v4l2loopback module for virtual camera support (commented out)

  # For more advanced configuration, refer to the video tutorial
  # https://www.youtube.com/watch?v=nJ6glhP7JI0
}