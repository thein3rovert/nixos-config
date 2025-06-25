# Reference: Host "fallarbor" aly
{
  config,
  self,
  pkgs,
  modulesPath,
  ...
}:

{
  # === Imports ===
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix") # Hardware scan
    (modulesPath + "/profiles/qemu-guest.nix") # QEMU guest profile
    ./disk-config.nix # Custom disk config
  ];

  # === System Settings ===
  system.stateVersion = "25.05"; # Required for NixOS system version compatibility
  networking.hostName = "wellsjaha"; # Hostname
  time.timeZone = "Europe/London"; # System timezone

  # === Boot Loader ===
  #TODO:: Move to shared user management later
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # === Internationalisation (i18n) ===
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # === System Packages ===
  environment.systemPackages = with pkgs; [
    btop
  ];

  nixosSetup = {
    profiles = {
      base.enable = true;
    };
  };

  # === Console ===
  console.keyMap = "uk"; # UK keyboard layout

  # === Environment Variables ===
  # environment.variables.GDK_SCALE = "1.25"; # UI scaling (for GTK apps)

  # === QEMU Guest Services ===
  services.qemuGuest.enable = true;

  # === User Management ===
  # === Password using "mkpasswd --method=yescrypt" ===
  myUsers = {
    thein3rovert = {
      enable = true;
      password = "$y$j9T$ijOefXV1SG7tcj6ALYFlW1$eROUM..nWeygQYzH3gD75IRwCiAf40NAx6R2OwUVIt9";
    };

    # newUser = {
    #   enable = true;
    #   password = "$y$j9T$OXQYhj4IWjRJWWYsSwcqf.$lCcdq9S7m0EAdej9KMHWj9flH8K2pUb2gitNhLTlLG/";
    # };
  };

  # === SSH Configuration ===
  #TODO:: Move to common or dedicated folder
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes"; # Disable root login over SSH
    allowSFTP = true; # Enable SFTP access
  };
}
