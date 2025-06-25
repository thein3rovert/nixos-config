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
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  # INFO: Keep hostname as host machine name.
  networking.hostName = "demo";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.kitty
    pkgs.cowsay

  ];

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

  # users.users.thein3rovert.ignoreShellProgramCheck = true;
  # programs.zsh.enable = true;
  time.timeZone = "Europe/London";

  system.stateVersion = "24.11";
}
