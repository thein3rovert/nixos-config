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
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../config # Contains hardware files
  ];
  boot.supportedFilesystems = [
    "ntfs"
    "vfat"
    "ext4"
  ];
  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.zramSwap

  # time.timeZone = "Europe/London";
  time.timeZone = "${theTimezone}";

  # Select internationalisation properties.
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

  # Configure console keymap
  console.keyMap = "uk";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Session Variables
  environment.sessionVariables = {
    FLAKE = "/home/thein3rovert/thein3rovert-flake"; # Specify nix path for nh used for easy rebuild
  };

  # === CUSTOM CONFIG AND SETTINGS
  # This settings contain custom enabled services
  # from modules

  nixosSetup = {
    programs = {
      podman.enable = true;
    };
    services = {
      minio.enable = true;
      tailscale.enable = true;
    };
  };

  # List packages installed in system profile. To search, run
  environment.systemPackages = with pkgs; [
    # ------------------------------
    # Essential Tools
    # ------------------------------
    vim # Text editor (Don't forget to add an editor to edit configuration.nix! Nano is also installed by default.)
    wget # Utility for downloading files from the web

    evolve-core # Core of the Evolve tool (purpose-specific package)

    # ------------------------------
    # CLI (Command Line Interface)
    # ------------------------------
    vim # Text editor
    git # Version control tool
    neovim # Modern text editor (alternative to vim)
    kitty # Terminal emulator
    # ddcutil                 # Brightness control (works via CLI)
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
    dunst # Notification daemon (GUI notifications)
    # libnotify              # Library for notifications (works with GUI tools)
    blueberry # Bluetooth configuration tool (GUI)
    sticky-notes
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
  ];

  nmod.fonts = {
    emoji = true;
    nerd = true;
  };
  systemd.services.kanata = {
    description = "Kanata Keyboard Manager";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "/etc/profiles/per-user/thein3rovert/bin/kanata -c /etc/kanata/kanata.kbd";
    serviceConfig.Restart = "always";
  };
  users.users.backupuser = {
    isNormalUser = true;
    description = "Backup User";
    extraGroups = [
      "wheel"
      "networkmanager"
    ]; # Gives sudo and network access
    hashedPassword = "$6$Zn6hrbZ2OCfR3GYU$mPzSIg7JU9V3EXZVLqcNrkIevpjf6cX5sQ4QFq8wJZ8RNY6Iu49D8P9aFtK8Gf6FbvDFmonRvQwhqOJxuK6qx/"; # Replace this or use `mkpasswd`
  };

  users.users.thein3rovert = {
    isNormalUser = true;
    description = "thein3rovert";
    extraGroups = [
      "wheel"
      "networkmanager"
      "sudo"
    ]; # Gives sudo and network access

    packages = [ inputs.home-manager.packages.${pkgs.system}.default ]; # This fix home-manager not showing on path
    initialHashedPassword = "$6$rTNa.yDm.2BaIJwX$p4z.EvBm9cmpovrM9FmQ5jvWyNrpuem.894A9X0lKVu5nvJMkNUP0CF1X/7LjkCd0Lf4UUQf67bhagYwboGdB0"; # Replace this or use `mkpasswd`
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  users.defaultUserShell = pkgs.zsh;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
