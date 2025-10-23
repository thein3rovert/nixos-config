# ==============================
#       Base Profile Module
# ==============================
# This module defines the base system configuration that serves as
# a foundation for NixOS systems.

{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  # ==============================
  #         Module Options
  # ==============================
  options.nixosSetup.profiles.base.enable = lib.mkEnableOption "All base system config when enabled";

  config = lib.mkIf config.nixosSetup.profiles.base.enable {
    # ==============================
    #    Environment Configuration
    # ==============================
    environment = {
      # Link the flake repo to /etc/nixos
      # When logged into the system, you can check /etc/nixos to
      # see what config source is being used
      etc."nixos".source = self;

      # ==============================
      #      System Packages
      # ==============================
      systemPackages = with pkgs; [
        # Override the inxi package to include recommended dependencies
        (inxi.override { withRecommends = true; })

        # Increase the priority of uutils-coreutils-noprefix to ensure it's selected
        (lib.hiPrio uutils-coreutils-noprefix)

        # Core system utilities
        git # Version control
        htop # Process viewer
        wget # File downloader
        rclone
        tmux
      ];

      # Variables needed by nix and nh
      variables = {
        FLAKE = lib.mkDefault "git+files:///home/thein3rovert/nixos-config";
        NH_FLAKE = lib.mkDefault "git+files:///home/thein3rovert/nixos-config";
      };
    };

    # ==============================
    #     Program Configuration
    # ==============================
    # TODO: Move program specific config to modules
    programs = {
      # Desktop configuration database
      dconf.enable = true;

      # Directory environment manager
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        #silent = true;    # Turn to true later, leave off for testing
      };

      # Nix helper tool
      nh.enable = true;

      # INFO: SSH known hosts configuration
      # Don't forget to add host to snippets
      # Example:
      # ssh.knownHosts = {
      #   "github.com" = {
      #     hostNames = [ "github.com" ];
      #     publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEc...";
      #   };
      # }
    };

    # ==============================
    #     Network Configuration
    # ==============================
    networking.networkmanager.enable = true;

    # ==============================
    #     Security Configuration
    # ==============================
    security = {
      # Enable sudo-rs, a memory-safe Rust implementation of sudo
      sudo-rs = {
        enable = true;
        # Allow users in the 'wheel' group to run sudo commands without a password
        wheelNeedsPassword = false;
      };

      # === Optional Security Services ===
      # polkit.enable = true;    # PolicyKit for defining and handling authorizations
      # rtkit.enable = true;     # RealtimeKit for real-time scheduling (audio apps)
    };

    # ==============================
    #     Service Configuration
    # ==============================
    services = {
      # === Network File System Caching ===
      # Start cachefilesd for disk caching of network filesystems (like NFS)
      # Begin culling when disk space drops below 20%
      # Continue culling until disk space rises above 10%
      # Stop all caching if disk space drops below 5%
      cachefilesd = {
        enable = true;
        extraConfig = ''
          brun 20%
          bcull 10%
          bstop 5%'';
      };

      # === SSH Server Configuration ===
      openssh = {
        enable = true;
        openFirewall = true; # Open port 22 in firewall
        settings.PasswordAuthentication = false; # Disable password login
      };

      # === Optional Services ===
      # vscode-server.enable = true;

      # === Network Discovery (Not needed yet) ===
      # avahi = {
      #   enable = true;     # Start Avahi daemon for mDNS/zeroconf discovery
      #   nssmdns4 = true;  # Enable .local hostname resolution over IPv4
      #   openFirewall = true;
      #   publish = {
      #     enable = true;      # Enable publishing on network
      #     addresses = true;   # Advertise IP addresses
      #     userServices = true;# Advertise user services
      #     workstation = true; # Announce as workstation
      #   };
      # };
    };

    # ==============================
    #     System Configuration
    # ==============================
    system = {
      # Records the current git revision or dirty revision
      # Helps track which configuration version was deployed
      configurationRevision = self.rev or self.dirtyRev or null;

      # Enable the next-generation nixos-rebuild tool
      rebuild.enableNg = true;
    };
  };
}
