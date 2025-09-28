# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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
  imports = [
    ./hardware-configuration.nix
    ../config # Contains system config
  ];

  boot.supportedFilesystems = [
    "ntfs"
    "vfat"
    "ext4"
  ];

  # ------------------------------------------------------
  # BOOTLOADER
  # -------------------------------------------------------

  # boot.loader.systemd-boot.enable = true;
  # INFO: Config present in config/ folder
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.enable = true;
  # boot.loader.grub.devices = [ "nodev" ];
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.useOSProber = true;

  # ------------------------------------------------------
  # NETWORKING
  # -------------------------------------------------------

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # ------------------------------------------------------
  # TIMEZONE
  # ------------------------------------------------------
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

  # Session Variables
  environment.sessionVariables = {
    # Specify nix path for nh used for easy rebuild
    FLAKE = "/home/thein3rovert/thein3rovert-flake";
  };

  # ------------------------------------------------
  # CUSTOM CONFIG AND SETTINGS
  # This settings contain custom enabled services from modules
  # -------------------------------------------------

  nixosSetup = {
    programs = {
      podman.enable = true;
      obs-studio.enable = true;
      vscode.enableFhs = true;
      virt-manager.enable = true;
    };
    #services = {
    #  minio.enable = true;
     # tailscale.enable = true;
    #};
  };

  # hardwareSetup.intel.cpu.enable = true;
  hardwareSetup = {
    intel = {
      cpu.enable = true;
      gpu.enable = true;
    };
  };

  coreModules = {
    hardware.enable = true;
    boot.enable = true;
    programs.enable = true;
    services.enable = true;
    security.enable = true;
  };

  # -----------------------------------------------------
  # NIXPKGS
  # -----------------------------------------------------
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  environment.systemPackages = with pkgs; [
    # ------------------------------
    # Essential Tools
    # ------------------------------

    input-leap # Mouse and Keyboard

    vim # Text editor
    wget # Utility for downloading files from the web

    # ------------------------------
    # CLI (Command Line Interface)
    # ------------------------------
    vim # Text editor
    git # Version control tool
    neovim # Modern text editor (alternative to vim)
    kitty # Terminal emulator
    sshfs # SSH file system (mount remote directories)
    lazydocker # CLI Docker management tool
    nh # Alternate to nix rebuild
    nvd # Assist nh with colorful output
    nix-output-monitor
    nix-ld # Nix dynamic library management tool
    nil
    nixd

    # ------------------------------
    # GUI (Graphical User Interface)
    # ------------------------------

    evolve-core # Core of the Evolve tool (purpose-specific package)
    dunst # Notification daemon (GUI notifications)
    blueberry # Bluetooth configuration tool (GUI)
    sticky-notes

    # libnotify              # Library for notifications (works with GUI tools)
    # qt5ct                   # Qt5 configuration tool (GUI-based)
    # qt6.qtwayland           # Wayland support for Qt6 (GUI apps)
    # qt6Packages.qtstyleplugin-kvantum # Kvantum style plugin for Qt6 (GUI-based)
    # libsForQt5.qtstyleplugin-kvantum # Kvantum style plugin for Qt5 (GUI-based)
    # gtk-engine-murrine      # GTK2 engine for theming (GUI)
    # tokyonight-gtk-theme    # GTK theme (for GUI)

    # ------------------------------
    # Other (Utilities or configurations not strictly CLI or GUI)
    # ------------------------------
    xdg-user-dirs # Utility for managing user directories
    xdg-utils # Utilities for working with XDG base directories
    inputs.zen-browser.packages."${system}".default # Zen Browser package (system-specific)
    networkmanagerapplet
    fuse # file system management for grub

    # Tunneling
    cloudflared
    cloudflare-warp
  ];

  systemd.services.warp-svc = {
    description = "Cloudflare WARP Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      Restart = "on-failure";
    };
  };

  # -------------------------------------
  # FONTS
  # --------------------------------------

  nmod.fonts = {
    emoji = true;
    nerd = true;
  };

  # --------------------------------------
  # CUSTOM KEYBOARD CONFIG
  # --------------------------------------

  # systemd.services.kanata = {
   # description = "Kanata Keyboard Manager";
    # wantedBy = [ "multi-user.target" ];
    # serviceConfig.ExecStart = "/etc/profiles/per-user/thein3rovert/bin/kanata -c /etc/kanata/kanata.kbd";
    # serviceConfig.Restart = "always";
  # };

  # --------------------------------------
  # RECOVERY USER AND HOME USER
  # --------------------------------------

  users.users.backupuser = {
    isNormalUser = true;
    description = "Backup User";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    hashedPassword = "$6$Zn6hrbZ2OCfR3GYU$mPzSIg7JU9V3EXZVLqcNrkIevpjf6cX5sQ4QFq8wJZ8RNY6Iu49D8P9aFtK8Gf6FbvDFmonRvQwhqOJxuK6qx/"; # Replace this or use `mkpasswd`
  };

  users.users.thein3rovert = {
    isNormalUser = true;
    description = "thein3rovert";
    extraGroups = [
      "wheel"
      "networkmanager"
      "sudo"
    ];
    # This fix home-manager not showing on path
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
    initialHashedPassword = "$6$rTNa.yDm.2BaIJwX$p4z.EvBm9cmpovrM9FmQ5jvWyNrpuem.894A9X0lKVu5nvJMkNUP0CF1X/7LjkCd0Lf4UUQf67bhagYwboGdB0"; # Replace this or use `mkpasswd`
  };

  # ------------------------------------
  # SHELL
  # ------------------------------------

  users.defaultUserShell = pkgs.zsh;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "24.11"; # Did you read the comment?

}
