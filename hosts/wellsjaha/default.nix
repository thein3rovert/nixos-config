# ==============================
#     Wellsjaha Host Configuration
# ==============================
# Test server configuration for development and experimentation
# Reference: Host "fallarbor" aly

{
  config,
  self,
  pkgs,
  modulesPath,
  ...
}:

{
  # ==============================
  #         Module Imports
  # ==============================
  imports = [
    # Hardware detection and QEMU guest support
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    # Host-specific configurations
    ./disk-config.nix
    ./home.nix

    # Custom modules
    self.nixosModules.locale-en-uk
  ];

  # ==============================
  #      System Configuration
  # ==============================
  system.stateVersion = "25.05";
  networking.hostName = "wellsjaha";

  # ==============================
  #     Network Configuration
  # ==============================
  # Static IP configuration
  networking.interfaces.enp1s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "10.20.0.1";
        prefixLength = 16;
      }
    ];
  };

  # Network routing and DNS
  networking.defaultGateway = "10.20.0.254";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # ==============================
  #      Time & Locale Setup
  # ==============================
  time.timeZone = "Europe/London";
  console.keyMap = "uk";

  # ==============================
  #      Boot Configuration
  # ==============================
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # ==============================
  #       System Packages
  # ==============================
  environment.systemPackages = with pkgs; [
    btop # System monitor
    kitty # Terminal emulator
  ];

  # ==============================
  #     Hardware Configuration
  # ==============================
  hardwareSetup.intel.cpu.enable = true;

  # ==============================
  #      Custom Module Setup
  # ==============================
  nixosSetup = {
    # Base system profile
    profiles = {
      base.enable = true;
    };

    # Program configurations
    programs = {
      podman.enable = true;
      vscode.enable = false;
      vscode.enableFhs = true;
    };
  };

  # ==============================
  #       QEMU Guest Services
  # ==============================
  services.qemuGuest.enable = true;

  # ==============================
  #       User Management
  # ==============================
  # Users configured with yescrypt password hashing
  myUsers = {
    thein3rovert = {
      enable = true;
      password = "$6$wNwBWd4.HvBEmqhB$utEc.ExmltqG/My6n4NRjfviUj6KLcq2Bi../F9SvoymICsUOP5OX09mg7MN73UnoXeoO7bhegaYqcLjZnMEE/";
    };
  };

  # ==============================
  #      SSH Configuration
  # ==============================
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    allowSFTP = true;
    banner = ''
       __     __     ______     __         __         ______       __     ______     __  __     ______    
      /\ \  _ \ \   /\  ___\   /\ \       /\ \       /\  ___\     /\ \   /\  __ \   /\ \_\ \   /\  __ \   
      \ \ \/ ".\ \  \ \  __\   \ \ \____  \ \ \____  \ \___  \   _\_\ \  \ \  __ \  \ \  __ \  \ \  __ \  
       \ \__/".~\_\  \ \_____\  \ \_____\  \ \_____\  \/\_____\ /\_____\  \ \_\ \_\  \ \_\ \_\  \ \_\ \_\ 
        \/_/   \/_/   \/_____/   \/_____/   \/_____/   \/_____/ \/_____/   \/_/\/_/   \/_/\/_/   \/_/\/_/ 
                                                                                      
                             Welcome to WellsJaha (NixOS) 🚀
    '';
  };

  # ==============================
  #     Nixpkgs Configuration
  # ==============================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}
