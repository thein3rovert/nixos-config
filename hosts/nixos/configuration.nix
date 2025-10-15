# ==============================
#     NixOS Configuration
# ==============================
{
  config,
  pkgs,
  inputs,
  self,
  ...
}:
let
  inherit (import ../../options.nix) theTimezone hostname;
in

{
  # ==============================
  #         Imports
  # ==============================
  imports = [
    ./hardware-configuration.nix
    ../config # Contains system config
  ];

  # ==============================
  #      Boot Configuration
  # ==============================
  boot.supportedFilesystems = [
    "ntfs"
    "vfat"
    "ext4"
  ];
  # NOTE: Bootloader config is handled in the config/ folder

  # ==============================
  #       Networking Setup
  # ==============================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Firewall configuration for LocalSend
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  # ==============================
  #    Localization & Timezone
  # ==============================
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

  console.keyMap = "uk";

  # ==============================
  #   Environment Variables
  # ==============================
  environment.sessionVariables = {
    # Specify nix path for nh used for easy rebuild
    FLAKE = "/home/thein3rovert/thein3rovert-flake";
  };

  # ==============================
  #     Custom Module Config
  # ==============================
  # Custom enabled services and programs from modules
  nixosSetup = {
    programs = {
      podman.enable = true;
      obs-studio.enable = true;
      vscode.enableFhs = true;
      virt-manager.enable = true;
    };
  };

  # Hardware-specific configurations
  hardwareSetup = {
    intel = {
      cpu.enable = true;
      gpu.enable = true;
    };
  };

  # Core system modules
  coreModules = {
    hardware.enable = true;
    boot.enable = true;
    programs.enable = true;
    services.enable = true;
    security.enable = true;
  };

  # ==============================
  #      Nixpkgs Configuration
  # ==============================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  # ==============================
  #      System Packages
  # ==============================
  environment.systemPackages = with pkgs; [
    # Essential system tools
    vim # Text editor
    wget # File downloader

    # Development and CLI tools
    git # Version control
    neovim # Modern text editor
    kitty # Terminal emulator
    sshfs # SSH filesystem
    lazydocker # Docker management
    nh # Alternative to nix rebuild
    nvd # Colorful nix output
    nix-output-monitor # Better nix build output
    nix-ld # Dynamic library management
    nil # Nix language server
    nixd # Another Nix language server

    # GUI applications
    evolve-core # Evolve tool core
    dunst # Notification daemon
    blueberry # Bluetooth manager
    sticky-notes # Note-taking app
    networkmanagerapplet # Network manager GUI

    # System utilities
    xdg-user-dirs # User directory management
    xdg-utils # XDG utilities
    fuse # Filesystem utilities
    gparted

    # Network and tunneling
    cloudflared # Cloudflare tunnel
    cloudflare-warp # Cloudflare WARP
    localsend # Local file sharing

    # Browser (system-specific)
    inputs.zen-browser.packages."${system}".default
    ansible
  ];

  # ==============================
  #       System Services
  # ==============================
  # Cloudflare WARP service
  systemd.services.warp-svc = {
    description = "Cloudflare WARP Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      Restart = "on-failure";
    };
  };

  # ==============================
  #         Font Setup
  # ==============================
  nmod.fonts = {
    emoji = true;
    nerd = true;
  };

  # ==============================
  #       User Accounts
  # ==============================
  # Backup/recovery user
  users.users.backupuser = {
    isNormalUser = true;
    description = "Backup User";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    hashedPassword = "$6$Zn6hrbZ2OCfR3GYU$mPzSIg7JU9V3EXZVLqcNrkIevpjf6cX5sQ4QFq8wJZ8RNY6Iu49D8P9aFtK8Gf6FbvDFmonRvQwhqOJxuK6qx/";
  };

  # Main user account
  users.users.thein3rovert = {
    isNormalUser = true;
    description = "thein3rovert";
    extraGroups = [
      "wheel"
      "networkmanager"
      "sudo"
    ];
    # Fix home-manager not showing on PATH
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
    initialHashedPassword = "$6$rTNa.yDm.2BaIJwX$p4z.EvBm9cmpovrM9FmQ5jvWyNrpuem.894A9X0lKVu5nvJMkNUP0CF1X/7LjkCd0Lf4UUQf67bhagYwboGdB0";
  };

  # ==============================
  #       Shell Configuration
  # ==============================
  users.defaultUserShell = pkgs.zsh;

  # ==============================
  #       Nix Configuration
  # ==============================
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ==============================
  #      System State Version
  # ==============================
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "24.11";
}
