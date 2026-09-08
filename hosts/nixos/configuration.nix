# ================================
#     NIXOS CONFIGURATION
# ================================
{
  config,
  inputs,
  pkgs,
  self,
  ...
}:
let
  inherit (import ../../options.nix) theTimezone hostname;
  homelab = config.homelab;
in

{
  # ================================
  #           IMPORTS
  # ================================
  imports = [
    ./hardware-configuration.nix
    ../config # Contains system config
  ];

  # ================================
  #      BOOT CONFIGURATION
  # ================================
  boot.supportedFilesystems = [
    "ext4"
    "ntfs"
    "vfat"
  ];
  # NOTE: Bootloader config is handled in the config/ folder

  # ================================
  #        CONSOLE SETUP
  # ================================
  console.keyMap = "uk";

  # ================================
  #      CORE SYSTEM MODULES
  # ================================
  coreModules = {
    boot.enable = true;
    hardware.enable = true;
    programs.enable = true;
    security.enable = true;
    services.enable = true;
  };

  # ================================
  #    ENVIRONMENT VARIABLES
  # ================================
  environment.sessionVariables = {
    # Specify nix path for nh used for easy rebuild
    FLAKE = "/home/thein3rovert/thein3rovert-flake";
    # AWS_ACCESS_KEY_ID = "$(cat ${config.age.secrets.minio_id.path})";
    # AWS_SECRET_ACCESS_KEY = "$(cat ${config.age.secrets.minio_secret.path})";
  };

  # ================================
  #       SYSTEM PACKAGES
  # ================================
  environment.systemPackages = with pkgs; [
    # ---- Essential System Tools ----
    vim # Text editor
    wget # File downloader

    # ---- Development and CLI Tools ----
    # TODO: MOVE TO CLI MODULES
    git # Version control
    neovim # Modern text editor
    kitty # Terminal emulator
    sshfs # SSH filesystem
    nh # Alternative to nix rebuild
    nvd # Colorful nix output
    nix-output-monitor # Better nix build output
    nix-ld # Dynamic library management
    nil # Nix language server
    nixd # Another Nix language server

    # Flox dev environment manager (from flake input)
    inputs.flox.packages.${pkgs.stdenv.hostPlatform.system}.default

    # ---- GUI Applications ----
    # TODO: MOVE TO DESKTOP MODULES
    dunst # Notification daemon
    # blueberry has been changed to blueman
    blueman # Bluetooth manager
    networkmanagerapplet # Network manager GUI
    # sticky-notes

    # ---- System Utilities ----
    xdg-user-dirs # User directory management
    xdg-utils # XDG utilities
    fuse # Filesystem utilities
    gparted
    banana-cursor
    kanata
    # ---- Network and Tunneling ----
    dig
    iptables
    tcpdump
    cloudflared # Cloudflare tunnel
    # localsend # Local file sharing
    # cloudflare-warp

    # ---- Infrastructure ----
    ansible
    terraform
    awscli
    minio-client
    kubernetes-helm
    podman-compose
    # firefox-unstable

    # ------ NFS --
    nfs-utils

    # ---- AI ----
    /*
      Building my custom package of this
      for updated version
    */
    github-copilot-cli

    bibata-cursors

  ];

  # ================================
  #     HARDWARE CONFIGURATION
  # ================================
  hardwareSetup = {
    intel = {
      cpu.enable = true;
      gpu.enable = true;
    };
  };

  # ================================
  #   INTERNATIONALIZATION & LOCALE
  # ================================
  time.timeZone = "${theTimezone}";
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

  # ================================
  #     NETWORKING CONFIGURATION
  # ================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.nameservers = [
    # Tailscale DNS
    # "100.100.100.100"
    # "1.1.1.1"
    # "8.8.8.8"

    # Default (Adguard)
    # "10.10.10.12" (Now using lxc as dns)
    # "10.135.108.10" # lxc andrew
  ];

  # NOTE: Disable router DNS, only needed if running adguard
  # networking.networkmanager.dns = "none";

  # Systemd + tailscale manage dns
  # services.resolved.enable = true;

  # ---- Firewall Configuration ----
  # NOTE: This is used by localsend, might consider
  # moving to localsend module sometimes
  # 3900 = Garage S3 API (reachable from bellamy Traefik over Tailscale - HML-036)
  networking.firewall.allowedTCPPorts = [
    53317
    3900
  ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  # ================================
  #        NIX CONFIGURATION
  # ================================
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Flox binary cache
    trusted-substituters = [ "https://cache.flox.dev" ];
    trusted-public-keys = [
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    ];
  };

  # ================================
  #    NIXOS CUSTOM MODULES
  # ================================
  nixosSetup = {
    containers = {
      freshrss.enable = false;
    };

    profiles = {
      base.enable = true;
      fonts = {
        enable = true;
        customFonts = [
          ../../modules/nixos/profiles/fonts/IoskeleyMono-Hinted
        ];
      };
      # ================================
      #     NFS CONFIGURATION
      # ================================
      nfs = {
        isClient = true;
        mounts = [
          {
            mountPoint = "/mnt/nightblood";
            device = "100.77.212.11:/srv/nfs";
          }
          {
            mountPoint = "/mnt/backups";
            device = "100.105.187.63:/backups";
          }
          # NOTE: /mnt/garage mount removed - garage now runs locally (HML-036)
        ];
      };
      /*
        NOTE: I did this to avoid agenix putting the filepath to the needed credentials
        instead fo the decrypted credential itself so this way makes sure that
        systemd server the decypted key when started.
      */
      systemd = {
        minio-client = {
          enable = true;
          user = "thein3rovert";
          accessKeySecretPath = config.age.secrets.garage_thein3rovert_id.path;
          secretKeySecretPath = config.age.secrets.garage_thein3rovert_secret.path;
          endpointUrl = "https://${config.snippets.thein3rovert.networkMap.garage-api.vHost}";
        };
        aws-cli = {
          enable = true;
          user = "thein3rovert";
          profile = "garage";
          accessKeySecretPath = config.age.secrets.garage_thein3rovert_id.path;
          secretKeySecretPath = config.age.secrets.garage_thein3rovert_secret.path;
        };
        proxmox = {
          enable = true;
        };

      };
    };

    programs = {
      fossflow.enable = true;
      incus.enable = true;
      jnix.enable = true;
      obs-studio.enable = true;
      podman.enable = true;
      podman-network.enable = true;
      virt-manager.enable = true;
      vscode.enableFhs = true;
    };

    services = {
      opencode-web = {
        enable = true;
        hostname = "0.0.0.0"; # listen on all interfaces so podman containers can reach it via host.containers.internal
      };
      syncthing = {
        enable = true;
        user = "thein3rovert";
        certFile = config.age.secrets.syncthing-cert.path;
        keyFile = config.age.secrets.syncthing-key.path;
        settings = {
          devices."laptop" = {
            id = "3WZCM3M-GFOGXKA-W6SFZOD-JFG3W6Q-3KTDKJV-DBJ2OLN-FB7IKO2-O2HHPAB";
            addresses = [ "dynamic" ];
          };
          folders."share" = {
            path = "/home/thein3rovert/Documents/resources/sync";
            devices = [ "laptop" ];
          };
        };
      };

      say-cheese.enable = true;

      # ================================
      #      GARAGE (migrated from bellamy VPS - HML-036)
      # ================================
      # Storage moved here because bellamy ran out of disk space.
      # Public S3 (s3.thein3rovert.dev) is still terminated by bellamy's
      # Traefik, which proxies to this host's Tailscale IP over port 3900.
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

          # [ ADMIN ]
          apiBindAddr = "127.0.0.1:${toString adminPort}"; # Only accessible locally

          rpcBindAddr = "0.0.0.0:${toString rpcPort}";
          rpcPublicAddr = "${config.homelab.ipAddresses.nixos.tailscaleIp}:${toString rpcPort}";

          # S3 API must be reachable from bellamy Traefik (Tailscale) and local garage-webui
          s3Api.apiBindAddr = "0.0.0.0:${toString apiPort}";
          s3Api.rootDomain = "s3.thein3rovert.dev";
        };

      # Garage Web UI (Noooste/garage-ui container) - now runs locally
      garage-webui =
        let
          webuiPort = 3909;
        in
        {
          enable = true;
          port = webuiPort;
          environmentFile = config.age.secrets.garage-webui-env.path;
          waitForServices = [ "garage.service" ];

          garageEndpoint = "127.0.0.1:3900";
          garageAdminEndpoint = "http://127.0.0.1:3903";
        };

      adguard.enable = false;
      prometheusNode.enable = true;
      promtail.enable = false;

      # Move to roan
      # zerobyte.enable = true;
      # dockhand.enable = false;

      hawser.enable = false;
      dockhand.enable = false;
      mysql.enable = false;
      n8n.enable = false;
      termix.enable = true;
      grafana.enable = true;
      copyparty.enable = true;
      fileshare.enable = true;
      dbpro-studio.enable = true;
      kaneo.enable = true;
      nginx = {
        enable = false;
        virtualHosts.default = {
          serverName = "localhost";
          root = "/var/www/localhost";
        };
      };
      postgresql.enable = true;
      pgadmin.enable = false; # Replace this with db pro
      tailscale = {
        enable = true;
      };
      traefikk.enable = true;
    };
  };

  # ================================
  #      NIXPKGS CONFIGURATION
  # ================================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  # ---- Insecure Packages ----
  # nixpkgs.config.permittedInsecurePackages = [
  #   "ventoy-1.1.07"
  # ];

  # ================================
  #         FONT SETUP
  # ================================
  nmod.fonts = {
    emoji = true;
    nerd = true;
  };

  # ================================
  #       PROGRAMS SETUP
  # ================================
  programs.sniffnet.enable = true;
  programs.ssh.knownHosts = config.snippets.ssh.knownHosts;

  # ================================
  #       SERVICES CONFIG
  # ================================
  services.openssh.extraConfig = ''
    PermitTTY yes
    PermitUserEnvironment yes
  '';

  services.kanata = {
    enable = true;
    keyboards.default = {
      extraDefCfg = "process-unmapped-keys yes";
      config = ''
        (defsrc
          bksl
        )

        (deflayer base
          /
        )
      '';
    };
  };

  # ---- Cloudflare WARP Service ----
  # systemd.services.warp-svc = {
  #   description = "Cloudflare WARP Daemon";
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
  #     Restart = "on-failure";
  #   };
  # };

  # ================================
  #        USER ACCOUNTS
  # ================================
  users.defaultUserShell = pkgs.zsh;

  # ---- Backup/Recovery User ----
  users.users.backupuser = {
    isNormalUser = true;
    description = "Backup User";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPassword = "$6$Zn6hrbZ2OCfR3GYU$mPzSIg7JU9V3EXZVLqcNrkIevpjf6cX5sQ4QFq8wJZ8RNY6Iu49D8P9aFtK8Gf6FbvDFmonRvQwhqOJxuK6qx/";
  };

  # ---- Main User Account ----
  users.users.thein3rovert = {
    isNormalUser = true;
    description = "thein3rovert";
    extraGroups = [
      "networkmanager"
      "sudo"
      "wheel"
    ];

    # Lexa ( Remove after adding base user config )
    openssh.authorizedKeys.keys = [
      # Termix Web Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnAVdCrGVxF7uTYsPHCzW80hezYMH/RYztGJtXn+Hy0"

      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID8TgAMiILb7nAoRfJZry+r/ELp8qrITV305fJdIq2qJ danielolaibi@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOHslvxbDHisZaTqmsly3ZfSERVOfoEN4qPcVzIzmvIK danielolaibi@gmail.com" # Marcus
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvUw5YDyQHeNZdKUhTYnP3KvpZwJtyF+yOhDQO04DHZ n8n"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILn4T/Q9bsxOai8CploVKs4eyuVahCPoCKmqxE84Xfud danielolaibi@gmail.com"
    ];

    # NOTE: Fix home-manager not showing on PATH
    packages = [ inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    initialHashedPassword = "$6$rTNa.yDm.2BaIJwX$p4z.EvBm9cmpovrM9FmQ5jvWyNrpuem.894A9X0lKVu5nvJMkNUP0CF1X/7LjkCd0Lf4UUQf67bhagYwboGdB0";
  };

  # ================================
  #      TEMP FIX
  # ================================
  # Resolving Asymmetric Routing in Tailscale with Subnet Routes
  networking.localCommands = ''
    ip rule add from 10.10.10.12 to 10.10.10.0/24 lookup main priority 5200 2>/dev/null || true
  '';

  # ================================
  #      SYSTEM STATE VERSION
  # ================================
  /*
    NOTE: This value determines the NixOS release from which the default
    settings for stateful data, like file locations and database versions
    on your system were taken. It's perfectly fine and recommended to leave
    this value at the release version of the first install of this system.
  */
  system.stateVersion = "24.11";
}
