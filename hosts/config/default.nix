{ config, pkgs, ... }:

{
  imports = [
    ./boot.nix
    # ./kernel.nix
    # ./intel-gpu.nix
      ./services.nix
    # ./printer.nix
    # ./opengl.nix
    # ./packages.nix
    # ./portals.nix
    # ./buildtools.nix
    # ./security.nix
    ./hardware.nix
    # ./nixSettings.nix -- Now moved to common folder
    # ./uxplay.nix
    # ./battery.nix
    # ./vm.nix
    # ./fonts.nix
    # ./vsftpd.nix
    #    ./dev -- fix zed later
  ];
}