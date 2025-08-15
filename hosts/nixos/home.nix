{
  self,
  inputs,
  lib,
  config,
  ...
}:
let

  # ---------------------
  # CUSTOM FLAKE MODULES
  # --------------------
  customImport = self.homeManagerModules.default;
  kittyConfig = ../../modules/home/thein3rovert/programs/kitty;
in
{
  home-manager.users.thein3rovert =
    { pkgs, ... }:
    {
      imports = [
        customImport
        kittyConfig

        # INFO: THESE HAVENT BE CREATED YET, they should first be created in the flake before import
        # self.homeManagerModules.default
        # self.inputs.agenix.homeManagerModules.default

        # TODO: Move all these to home modules
        # ../../home/features/cli
        # ../../home/features/coding
        # ../../home/features/desktop
      ];

      home = {
        # ------------------------------
        # HOME USER
        # ------------------------------

        username = lib.mkDefault "thein3rovert";
        homeDirectory = lib.mkDefault "/home/${config.home.username}";

        # ------------------------------
        # HOME PACKAGES
        # ------------------------------

        packages = with pkgs; [
          btop
          zed-editor
          cowsay
          kitty
          wofi
          wlogout
          hyprlock
          blueman
          pavucontrol
          playerctl
          brightnessctl
        ];
        stateVersion = "24.05";
      };

      # ------------------------------------
      # PROGRAM
      # -------------------------------------

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      programs.waybar.enable = true;

      programs.ssh = {
        enable = true;
        matchBlocks = {
          vps-het-1 = {
            hostname = "95.216.211.225";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert-cloud";
          };
          demo = {
            hostname = "192.168.122.36";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert";
          };

          # === Test Server ===
          wellsjaha = {
            hostname = "192.168.122.100";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert";
          };

        };
      };

      # ------------------------------------
      # CUSTOM MODULES
      # ------------------------------------
      # features = {
      #   cli = {
      #     zsh.enable = true;
      #   };
      # };

      homeSetup = {
        # desktop.gnome.enable = true;
        thein3rovert = {
          packages.cli.enable = true;

          programs.git.enable = true;
          packages.coding.enable = true;
          programs.zsh.enable = true;
          programs.starship.enable = true;
          packages.desktop.enable = true;
        };
      };

      # ------------------------------------
      # NIX SETTINGS
      # ------------------------------------

      nix = {
        package = lib.mkDefault pkgs.nix;
        settings = {
          experimental-features = "nix-command flakes"; # === Enable flakes and nix-command ===
          trusted-users = [
            "root"
            "thein3rovert"
          ];
        };

        # -------------------------------------------------
        # CLEANUP AND OPTIMISATION
        # -------------------------------------------------

        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
        };

        # FIX: Redundant
        # optimise.automatic = true;

        # === Register all flake inputs as nix registry entries ===
        registry = lib.mapAttrs (_: flake: { inherit flake; }) (
          lib.filterAttrs (_: lib.isType "flake") inputs
        );

        # === Set custom NIX_PATH ===
        nixPath = [ "/etc/nix/path" ];
      };
    };
}
