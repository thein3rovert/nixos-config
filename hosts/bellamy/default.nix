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
        endpointUrl = "https://${config.snippets.thein3rovert.networkMap.storage3.vHost}";
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

      garage-webui =
        let
          region = "garage";
          apiPort = 3900;
          webuiPort = 3909;
          adminPort = 3903;
          garageWebuiEnv = config.age.secrets.garage-webui-env.path;
        in
        {
          enable = true;
          port = webuiPort;
          environmentFile = garageWebuiEnv;
          waitForServices = [ "garage.service" ];

          # Module options (can be overridden by environmentFile)
          apiBaseUrl = "http://127.0.0.1:${toString adminPort}";
          s3Region = region;
          s3EndpointUrl = "http://127.0.0.1:${toString apiPort}";
        };

      # TODO: Learn better way to use agenix fpr env
      garage =
        let
          apiPort = 3900;
          rpcPort = 3901;
          adminPort = 3903;
        in
        {
          enable = true;
          user = "thein3rovert";
          group = "users";
          metadataDir = "/var/storage/garage/meta";
          dataDir = "/var/storage/garage/data";
          # rpcSecret = builtins.readFile config.age.secrets.rpcSecret.path;
          # adminToken = builtins.readFile config.age.secrets.adminToken.path;

          # [ ADMIN ]
          apiBindAddr = "127.0.0.1:${toString adminPort}"; # Only accessible locally

          rpcBindAddr = "0.0.0.0:${toString rpcPort}";
          rpcPublicAddr = "127.0.0.1:${toString rpcPort}";
          # S3 API should listen on all interfaces so reverse proxy can reach it

          s3Api.apiBindAddr = "127.0.0.1:${toString apiPort}"; # Only accessible locally
          s3Api.rootDomain = "s3.thein3rovert.dev";

          # s3Web.rootDomain = "s3-web.thein3rovert.dev";
          # s3Web.bindAddr = "127.0.0.1:3902";
        };
    };

    programs = {
      podman.enable = true;
    };
  };

  # ==============================
  #      NFS Configuration
  # ==============================
  services.nfs.server = {
    enable = true;
    exports = ''
      /backups 10.10.10.12(rw,sync,no_subtree_check)
       /backups 100.0.0.0/8(rw,sync,no_subtree_check)
    '';
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
