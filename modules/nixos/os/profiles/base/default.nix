{
  config,
  lib,
  pkgs,
  self,
  ...
}:
{
  options.nixosSetup.profiles.base.enable = lib.mkEnableOption "All base system config when enabled";
  config = lib.mkIf config.nixosSetup.profiles.base.enable {
    environment = {
      # === Link the flake repo to /etc/nixos
      # when logged into the system, you can check /etc'nixos to
      # see what config source is being used.
      etc."nixos".source = self;

      systemPackages = with pkgs; [
        (inxi.override { withRecommends = true; }) # Meaning?
        (lib.hiPrio uutils-coreutils-noprefix) # Meaning?
        git
        htop
        wget
        rclone
        zellij # Similar to tmux
        nh
      ];

      #INFO: Variables options used by nix and needed by nh
      variables = {
        FLAKE = lib.mkDefault "git+files:///home/thein3rovert/thein3rovert-flake";
        # NH_FLAKE = lib.mkDefault "git+files:///home/thein3rovert/thein3rovert-flake";
      };
    };

    #TODO:  Move program specific config to a modules
    programs = {
      dconf.enable = true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        #silent = true;    # Turn to true later, leave off for testing
      };
      nh.enable = true;
      #
      #   #INFO: Dont forget to add host to snippets
      #   # ssh.knownHosts = config.mySnippets.ssh.knownHosts;
      #   # === Example ===
      #   # ssh.knownHosts = {
      #   #   "github.com" = {
      #   #     hostNames = [ "github.com" ];
      #   #     publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEc...";
      #   #   };
      #   # }
    };
    # networking.networkmanager.enable = true;

    security = {
      # Enable PolicyKit, a toolkit for defining and handling authorizations
      polkit.enable = true;
      # Enable RealtimeKit, which is used to grant real-time scheduling to user processes (e.g., audio applications)
      rtkit.enable = true;

      sudo-rs = {
        # Enable sudo-rs, a memory-safe Rust implementation of sudo
        enable = true; # Understand how sudo-rs works
        # Allow users in the 'wheel' group to run sudo commands without a password
        wheelNeedsPassword = false;
      };
    };

    services = {
      # === Not needed yet ===
      # avahi = {
      #   enable = true; # Start the Avahi daemon for local network (mDNS/zeroconf) discovery (Bonjour/Apple-style).
      #   nssmdns4 = true; # Enable name resolution for `.local` hostnames over IPv4.
      #   openFirewall = true; # Automatically open necessary firewall ports for Avahi/mDNS.
      #
      #   publish = {
      #     enable = true; # Enable publishing (advertising) this machine on the network.
      #     addresses = true; # Advertise the machine's IP addresses.
      #     userServices = true; # Advertise user-level services (e.g., printers, file shares).
      #     workstation = true; # Announce as a generic workstation.
      #   };
      # };

      cachefilesd = {
        enable = true; # Start cachefilesd, which provides disk caching for network filesystems (like NFS).

        extraConfig = ''
          brun 20%    # Begin culling (removing cache) when disk space drops below 20%.
          bcull 10%   # Continue culling until disk space rises above 10%.
          bstop 5%    # Stop all caching if disk space drops below 5%.
        '';
      };

      # vscode-server.enable = true;

      # openssh = {
      #   enable = true;
      #   openFirewall = true;
      #   settings.PasswordAuthentication = false;
      # };
    };

    # === Enable advance nixos rebuild ===
    system = {
      # Records the current git revision (commit hash) or, if dirty, the dirty revision;
      # helps track exactly which version of the configuration was deployed.
      configurationRevision = self.rev or self.dirtyRev or null;

      # Enables the next-generation nixos-rebuild (nixos-rebuild-ng) tool for system updates.
      rebuild.enableNg = true;
    };

  };
}
