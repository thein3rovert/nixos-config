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
  #      Homelab Configuration
  /*
    INFO: If this is set to false, all homelab services will be
    disabled
  */
  # ==============================
  # homelab.enable = true;

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
        endpointUrl = "https://${config.snippets.thein3rovert.networkMap.garage-api.vHost}";
      };
      nfs = {
        isServer = true;
        exports = ''
          /backups 10.10.10.12(rw,sync,no_subtree_check)
           /backups 100.0.0.0/8(rw,sync,no_subtree_check)

           # NOTE: /var/storage/garage export removed - garage migrated to nixos host (HML-036)
        '';
      };
    };
    containers = {
      freshrss.enable = true;
    };
    services = {
      traefik = {
        enable = true;
      };
      blog.enable = true;
      tailscale.enable = true;
      linkding.enable = true;
      glance.enable = true;
      uptime-kuma.enable = true;
      # jotty.enable = true; Replace with memos
      memos.enable = true;
      say-cheese.enable = true;

      # NOTE: Garage + garage-webui migrated to the nixos host (HML-036)
      # because this VPS ran out of disk space. This host's Traefik still
      # terminates s3.thein3rovert.dev and proxies to the nixos host over
      # Tailscale (via homelab.ipRegistry.garage).
      # Disabled: MinIO abandoned upstream with multiple CVEs, using Garage instead
      minio.enable = false;
      garage.enable = false;
      garage-webui.enable = false;
      hawser.enable = true;
      forgejo = {
        enable = true;
        database = "postgresql";
      };
      prometheusNode.enable = true;
      # No longer supported and maintained swithing to alloy
      promtail.enable = false;
    };

    programs = {
      podman.enable = true;
    };
  };

  # ==============================
  #      NFS Configuration
  # ==============================
  # services.nfs.server = {
  #   enable = true;
  #   exports = ''
  #     /backups 10.10.10.12(rw,sync,no_subtree_check)
  #     /backups 100.0.0.0/8(rw,sync,no_subtree_check)

  #     /var/storage/garage 10.10.10.12(ro,sync,no_subtree_check)
  #     /var/storage/garage 100.0.0.0/8(ro,sync,no_subtree_check)
  #   '';
  # };

  # ==============================
  #      SSH Configuration
  # ==============================
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      Banner = "/etc/motd";
    };
    allowSFTP = true;

  };

  # ==============================
  #     Nixpkgs Configuration
  # ==============================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}
