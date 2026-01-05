{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "marcus"; # Change this
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "Europe/London"; # Change as needed
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "us";

  users.users.thein3rovert = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO thein3rovert"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [
        "thein3rovert"
        "root"
      ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  security.sudo.wheelNeedsPassword = false;

  # SSH for remote management
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  system.stateVersion = "25.05";
}
