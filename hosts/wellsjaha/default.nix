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
    self.nixosModules.locale-en-uk
    ./home.nix
    ./secrets.nix
    # ./audiobookShelf.nix
  ];

  # === System Settings ===
  system.stateVersion = "25.05"; # Required for NixOS system version compatibility
  networking.hostName = "wellsjaha"; # Hostname
  networking.interfaces.enp1s0.ipv4.addresses = [
    {
      address = "192.168.122.100";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.122.1";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  time.timeZone = "Europe/London"; # System timezone

  # === Boot Loader ===
  #TODO:: Move to shared user management later
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # === System Packages ===
  environment.systemPackages = with pkgs; [
    btop
    kitty
  ];

  # Enable FHS compatibility for VS Code Server
  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   stdenv.cc.cc.lib
  #   zlib
  #   openssl
  #   libkrb5
  #   util-linux
  #   glibc
  # ];

  # === Hardware Config ===
  hardwareSetup.intel.cpu.enable = true;

  nixosSetup = {
    profiles = {
      base.enable = true;
    };

    programs = {
      podman.enable = true;
      vscode.enable = false;
      vscode.enableFhs = true;
    };

    services = {
      minio.enable = false; # Disable mini for now
      tailscale.enable = true;

      audiobookshelf = {
        enable = true;
        audiobookshelf-ts-authKeyFile = config.age.secrets.audiobookshelf.path;
      };
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
  #
  myUsers = {
    thein3rovert = {
      enable = true;
      # password = "$y$j9T$ijOefXV1SG7tcj6ALYFlW1$eROUM..nWeygQYzH3gD75IRwCiAf40NAx6R2OwUVIt9";
      password = "$6$wNwBWd4.HvBEmqhB$utEc.ExmltqG/My6n4NRjfviUj6KLcq2Bi../F9SvoymICsUOP5OX09mg7MN73UnoXeoO7bhegaYqcLjZnMEE/";
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

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}
