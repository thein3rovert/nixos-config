# ==============================
#     Bellamy Host Configuration
# ==============================

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
    git
    vim
    # Making sure python and pexpect come from the same package
    (python3.withPackages (ps: [ ps.pexpect ]))
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
      /*
        NOTE: I did this to avoid agenix putting the filepath to the needed credentials
        instead fo the decrypted credential itself so this way makes sure that
        systemd server the decypted key when started.
      */
      systemd.minio-client = {
        enable = true;
        user = "thein3rovert";
        accessKeySecretPath = config.age.secrets.garage_thein3rovert_id.path;
        secretKeySecretPath = config.age.secrets.garage_thein3rovert_secret.path;
      };
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

      # TODO: Learn better way to use agenix fpr env
      garage = {
        enable = true;
        user = "thein3rovert";
        group = "users";
        metadataDir = "/var/storage/garage/meta";
        dataDir = "/var/storage/garage/data";
        # rpcSecret = builtins.readFile config.age.secrets.rpcSecret.path;
        # adminToken = builtins.readFile config.age.secrets.adminToken.path;
        webBindAddr = "127.0.0.1:3902"; # Only accessible locally
        rpcBindAddr = "0.0.0.0:3901";
        rpcPublicAddr = "127.0.0.1:3901";
        # S3 API should listen on all interfaces so reverse proxy can reach it
        s3Api.apiBindAddr = "127.0.0.1:3900"; # Only accessible locally
        s3Api.rootDomain = "s3.thein3rovert.dev";

        s3Web.rootDomain = "s3-web.thein3rovert.dev";
        s3Web.bindAddr = "127.0.0.1:3902";
      };
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
