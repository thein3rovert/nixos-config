# ==============================
#    Home Manager Configuration
# ==============================
# Home Manager configuration for the nixos host
# Manages user environment and dotfiles

{
  self,
  inputs,
  lib,
  config,
  ...
}:
let
  # ==============================
  #      Module Definitions
  # ==============================
  # Custom flake modules
  customImport = self.homeManagerModules.default;
  kittyConfig = ../../modules/home/thein3rovert/programs/kitty;

  # ==============================
  #      SSH Configuration
  # ==============================
  # Default SSH settings applied to all hosts
  defaultSSHConfig = {
    forwardAgent = false;
    controlMaster = "no";
    userKnownHostsFile = "~/.ssh/known_hosts";
    compression = false;
    serverAliveCountMax = 3;
    serverAliveInterval = 0;
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "no";
    hashKnownHosts = false;
    addKeysToAgent = "no";
  };
in
{
  # ==============================
  #      Home Manager Setup
  # ==============================
  home-manager.users.thein3rovert =
    { pkgs, ... }:
    {
      # ==============================
      #         Module Imports
      # ==============================
      imports = [
        customImport
        kittyConfig
      ];

      # ==============================
      #      Home Configuration
      # ==============================
      home = {
        # User identity
        username = lib.mkDefault "thein3rovert";
        homeDirectory = lib.mkDefault "/home/${config.home.username}";

        # User packages
        packages = with pkgs; [
          # System monitoring and utilities
          btop # Resource monitor

          # Development and editing
          zed-editor # Modern text editor
          kitty # Terminal emulator

          # Desktop environment tools
          wofi # Application launcher
          wlogout # Logout menu
          hyprlock # Screen locker
          waybar # Status bar (configured separately)

          # Hardware control
          blueman # Bluetooth manager
          pavucontrol # Audio control
          playerctl # Media player control
          brightnessctl # Brightness control

          # Fun utilities
          cowsay # ASCII art messages
        ];

        # Home Manager state version
        stateVersion = "24.05";
      };

      # ==============================
      #      Program Configuration
      # ==============================
      # Core programs
      programs.home-manager.enable = true;
      programs.waybar.enable = true;

      # ==============================
      #       SSH Configuration
      # ==============================
      programs.ssh = {
        enableDefaultConfig = false;
        enable = true;
        matchBlocks = {
          # Production VPS
          vps-het-1 = lib.recursiveUpdate defaultSSHConfig {
            hostname = "95.216.211.225";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert-cloud";
          };

          # Demo/development server
          demo = lib.recursiveUpdate defaultSSHConfig {
            hostname = "192.168.122.36";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert";
          };

          # GitHub repository access
          "github.com" = lib.recursiveUpdate defaultSSHConfig {
            hostname = "github.com";
            identityFile = "~/.ssh/github/thein3rovert_github";
            user = "git";
          };

          # Test servers
          wellsjaha = lib.recursiveUpdate defaultSSHConfig {
            hostname = "10.20.0.1";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert";
          };

          octavia = lib.recursiveUpdate defaultSSHConfig {
            hostname = "10.20.0.2";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert";
          };
        };
      };

      # ==============================
      #      Custom Module Setup
      # ==============================
      homeSetup = {
        thein3rovert = {
          # Package collections
          packages.cli.enable = true;
          packages.coding.enable = true;
          packages.desktop.enable = true;

          # Program configurations
          programs.git.enable = true;
          programs.zsh.enable = true;
          programs.starship.enable = true;
        };
      };

      # ==============================
      #      Nix Configuration
      # ==============================
      nix = {
        package = lib.mkDefault pkgs.nix;

        # Nix settings and features
        settings = {
          experimental-features = "nix-command flakes";
          trusted-users = [
            "root"
            "thein3rovert"
          ];
        };

        # Garbage collection
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
        };

        # Flake registry setup
        registry = lib.mapAttrs (_: flake: { inherit flake; }) (
          lib.filterAttrs (_: lib.isType "flake") inputs
        );

        # Custom NIX_PATH
        nixPath = [ "/etc/nix/path" ];
      };
    };
}
