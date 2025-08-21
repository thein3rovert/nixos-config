{ config, pkgs, ... }:

{
  imports = [
    # Core system configurations
    # ./boot.nix
    # ./hardware.nix
    ./security.nix
    ./vm.nix

    # Graphics and GPU
    ./intel-gpu.nix
    ./opengl.nix

    # Services and programs
    ./services.nix
    # ./programs.nix

    # Development tools and environments
    ./dev

    # Fonts and UI (commented or active as per current usage)
    ./fonts
    # ./fonts.nix
    # ./uxplay.nix
    # ./battery.nix

    # Optional or currently unused features
    # ./kernel.nix
    # ./printer.nix
    # ./packages.nix
    # ./portals.nix
    # ./buildtools.nix
    # ./nixSettings.nix  # Now moved to common folder
    # ./vsftpd.nix
  ];
}
