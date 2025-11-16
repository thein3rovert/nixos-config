# ==============================
#     Bellamy Host Configuration
# ==============================
# Production server configuration

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
    ./secrets.nix

    # Custom modules
    self.nixosModules.locale-en-uk
  ];

  # ==============================
  #      System Configuration
  # ==============================
  system.stateVersion = "25.05";
  networking.hostName = "Bellamy";

  # ==============================
  #     Network Configuration
  # ==============================

  # ==============================
  #      Time & Locale Setup
  # ==============================
  time.timeZone = "Europe/London";
  console.keyMap = "uk";

  # ==============================
  #      Boot Configuration
  # ==============================
  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "sd_mod"
      "sr_mod"
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];

    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  # ==============================
  #       System Packages
  # ==============================
  environment.systemPackages = with pkgs; [
    btop # System monitor
    cowsay
    git
    vim
    minio-client
  ];

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
      password = "$6$ZC/D.G6TTr6RCi1H$VY3ycpSGrVdlhn9KZSdeCOhHLaSSuDNpFUpwt5L4NTrlkCcSahfcE/1sRAX2cgGxEMPHR.lUrWaPv25selFRP1";
    };
  };

  environment.etc."motd".text = ''
    ▗▄▄▖ ▗▄▄▄▖▗▖   ▗▖    ▗▄▖ ▗▖  ▗▖▗▖  ▗▖
    ▐▌ ▐▌▐▌   ▐▌   ▐▌   ▐▌ ▐▌▐▛▚▞▜▌ ▝▚▞▘ 
    ▐▛▀▚▖▐▛▀▀▘▐▌   ▐▌   ▐▛▀▜▌▐▌  ▐▌  ▐▌  
    ▐▙▄▞▘▐▙▄▄▖▐▙▄▄▖▐▙▄▄▖▐▌ ▐▌▐▌  ▐▌  ▐▌  

    Welcome, ${builtins.getEnv "USER"}! 🎉
  '';

  # ==============================
  #      Custom Module Setup
  # ==============================
  nixosSetup = {
    profiles = {
      base.enable = true;
      server.enable = true;
    };
    containers = {
      freshrss.enable = true;
    };
    services = {
      traefik = {
        enable = true;
      };
      tailscale.enable = true;
      linkding.enable = true;
      glance.enable = true;
      uptime-kuma.enable = true;
      jotty.enable = true;
      minio.enable = true;
    };

    programs = {
      podman.enable = true;
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
          ▗▄▄▖ ▗▄▄▄▖▗▖   ▗▖    ▗▄▖ ▗▖  ▗▖▗▖  ▗▖
          ▐▌ ▐▌▐▌   ▐▌   ▐▌   ▐▌ ▐▌▐▛▚▞▜▌ ▝▚▞▘ 
          ▐▛▀▚▖▐▛▀▀▘▐▌   ▐▌   ▐▛▀▜▌▐▌  ▐▌  ▐▌  
          ▐▙▄▞▘▐▙▄▄▖▐▙▄▄▖▐▙▄▄▖▐▌ ▐▌▐▌  ▐▌  ▐▌  

      Welcome to Bellamy Production Server (NixOS) 🚀
    '';
  };

  # ==============================
  #     Nixpkgs Configuration
  # ==============================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}
