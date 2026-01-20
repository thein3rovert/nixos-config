#INFO: This home-manager config is meant to be shared by all user thein3rovert
# but is it currently broken somehow and i'm trying to fix it.
{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  inherit (lib)
    mkMerge
    mkIf
    ;
in
{
  imports = [ self.homeManagerModules.default ];

  /*
    NOTE:
        lib.mkMerge in Nix merges a list of attribute sets,
        combining them left to right

     The file uses lib.mkIf to apply specific configurations
     based on the operating system: Darwin or Linux
  */
  config = mkMerge [
    #--------------------------------------
    # DEFAULT
    #--------------------------------------
    {
      home = {
        packages =
          with pkgs;
          [
            curl
            # nixos-rebuild-ng
            rclone
          ]
          ++ [
            htop
          ];

        username = "thein3rovert";
      };

      programs = {
        home-manager.enable = true;
        bash.enable = true;
      };

      xdg.enable = true;

      # ------------------------------
      # CUSTOM MODULES IMPORT
      # ------------------------------

      # Enable shell configuration with ZSH and Powerlevel10k
      homeSetup.shell.enable = true;
      # homeSetup.programs.agent.enable = true;
    }

    # ------------------------------
    # TODO: Add config for different OS (Darwin)
    # ------------------------------
    (lib.mkIf pkgs.stdenv.isDarwin {
      home = {
        homeDirectory = "/Users/thein3rovert";
        shellAliases."docker" = "podman";
      };
    })

    # ---------------
    # FOR LINUX
    # ----------------

    # FIX: isLinux not working on linux system
    # NOTE: Not applying config to linux system

    (mkIf pkgs.stdenv.isLinux {
      # gtk.gtk3.bookmarks = lib.mkAfter [
      #   "file://${config.home.homeDirectory}/sync"
      # ];
      home = {
        homeDirectory = "/home/thein3rovert";

        packages = with pkgs; [
          btop
          # obsidian
        ];

        stateVersion = "25.11";
        username = "thein3rovert";
      };

      # systemd.user.startServices = true; # Needed for auto-mounting agenix secrets.
    })
  ];
}
