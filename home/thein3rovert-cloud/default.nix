# INFO: This file is not being used yet, it can be inherited
# in the home.nix file instead
{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  imports = [
    # self.homeManagerModules.default
  ];

  config = lib.mkMerge [
    {
      home = {
        # packages = with pkgs; [
        #   curl
        #   nixos-rebuild-ng
        #   rclone
        #   wget
        # ];

        username = "thein3rovert-cloud";
      };

      programs.home-manager.enable = true;
      xdg.enable = true;

    }

    (lib.mkIf pkgs.stdenv.isDarwin {
      home = {
        homeDirectory = "/Users/thein3rovert-cloud";
        shellAliases."docker" = "podman";
      };

    })

    (lib.mkIf pkgs.stdenv.isLinux {
      gtk.gtk3.bookmarks = lib.mkAfter [
        "file://${config.home.homeDirectory}/sync"
      ];

      home = {
        homeDirectory = "/home/thein3rovert-cloud";

        packages = with pkgs; [
          btop
        ];

        stateVersion = 25.05;
        username = "thein3rovert-cloud";
      };

      systemd.user.startServices = true; # Needed for auto-mounting agenix secrets.

    })
  ];
}
