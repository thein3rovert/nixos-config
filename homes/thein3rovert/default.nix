{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  imports = [ self.homeManagerModules.default ];

  /*
    NOTE:
        lib.mkMerge in Nix merges a list of attribute sets,
        combining them left to right

     The file uses lib.mkIf to apply specific configurations
     based on the operating system: Darwin or Linux
  */
  config = lib.mkMerge [

    #--------------------------------------
    # DEFAULT
    #--------------------------------------
    {
      home = {
        packages =
          with pkgs;
          [
            curl
            nixos-rebuild-ng
            rclone
          ]
          ++ [
            htop
          ];

        username = "thein3rovert";
      };

      programs.home-manager.enable = true;
      xdg.enable = true;

      # ------------------------------
      # CUSTOM MODULES IMPORT
      # ------------------------------

    }

    # ------------------------------
    # TODO: Add config for different OS (Darwin)
    # ------------------------------

    # ---------------
    # FOR LINUX
    # ----------------

    # FIX: isLinux not working on linux system
    # NOTE: Not applying config to linux system

    (lib.mkIf pkgs.stdenv.isLinux {
      # gtk.gtk3.bookmarks = lib.mkAfter [
      #   "file://${config.home.homeDirectory}/sync"
      # ];
      home = {
        homeDirectory = "/home/thein3rovert";

        packages = with pkgs; [
          btop
          nixd
        ];

        stateVersion = "25.05";
        username = "thein3rovert";
      };

      systemd.user.startServices = true; # Needed for auto-mounting agenix secrets.
    })
  ];
}
