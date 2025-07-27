{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  # I dont need import yet
  imports = [ self.homeManagerModules.default ];

  /*
    NOTE:
        lib.mkMerge in Nix merges a list of attribute sets,
        combining them left to right

        In my case the attr set are a set of operating system
        types
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
            rclone
            curl
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
    # LINUX
    # ----------------

    (lib.mkIf pkgs.stdenv.isLinux {
      # gtk.gtk3.bookmarks = lib.mkAfter [
      #   "file://${config.home.homeDirectory}/sync"
      # ];

      home = {
        homeDirectory = "/home/thein3rovert";

        packages = with pkgs; [
          btop
        ];

        stateVersion = "25.05";
        username = "thein3rovert";
      };

      systemd.user.startServices = true; # Needed for auto-mounting agenix secrets.
    })
  ];
}
