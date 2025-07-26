#INFO: Gotten from nixos anywhere example
# https://github.com/nix-community/nixos-anywhere-examples/blob/main/configuration.nix
{
  modulesPath,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  # ------------------------------------
  # USER CONFIGURATION
  # ------------------------------------

  users.users.thein3rovert = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
    # Add ssh keys
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe danielolaibi@gmail.com"
    ];
  };

  # ------------------------------------
  # BOOTLOADER
  # ------------------------------------

  boot.loader.grub = {
    # No need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # ------------------------------------
  # SERVICES
  # ------------------------------------

  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  # ------------------------------------
  # NETWORKING
  # ------------------------------------

  networking.hostName = "demo";

  # ------------------------------------
  # PACKAGES
  # ------------------------------------

  nixpkgs.hostPlatform = "x86_64-linux";
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.kitty
    pkgs.cowsay

  ];

  # ------------------------------------
  # CUSTOM MODULES
  # ------------------------------------

  nixosSetup = {
    programs = {
      podman.enable = true;
    };
  };

  # ------------------------------------
  # SECURITY
  # ------------------------------------
  security.sudo.extraRules = [
    {
      users = [ "thein3rovert" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ------------------------------------
  # PROGRAM
  # ------------------------------------

  # programs.zsh.enable = true;

  time.timeZone = "Europe/London";
  system.stateVersion = "24.11";
}
