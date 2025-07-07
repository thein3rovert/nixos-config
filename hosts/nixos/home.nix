{
  self,
  inputs,
  lib,
  config,
  ...
}:
{
  home-manager.users.thein3rovert =
    { pkgs, ... }:
    {
      imports = [
        # INFO: THESE HAVENT BE CREATED YET, they should first be created in the flake before import
        # self.homeManagerModules.default
        # self.inputs.agenix.homeManagerModules.default
        # ../../home-manager/apps
        # ../../home-manager/modules
        ../../home/features/cli
        ../../home/features/coding
        ../../home/features/desktop
      ];

      home = {
        homeDirectory = "/home/thein3rovert";

        packages = with pkgs; [
          btop
          cowsay
          kitty
          wofi
          zed-editor

          # Make sure to move all this to the right config files later
          wlogout
          hyprlock

          blueman

          pavucontrol
          playerctl

          brightnessctl
        ];

        stateVersion = "24.05";
        username = "thein3rovert";
      };
      programs = {
        # helix = {
        #   enable = true;
        #   defaultEditor = true;
        # };

        home-manager.enable = true;
      };

      features = {
        cli = {
          zsh.enable = true;
          # fzf.enable = false;
        };
      };

      ########
      # WAYBAR
      ########
      programs.waybar = {
        enable = true;
      };

      home.sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        #Hint electron apps to use wayland
        NIXOS_OZONE_WL = "1"; # cant use this now
      };

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
            hostname = "192.168.122.142";
            identityFile = "~/.ssh/id_ed25519";
            user = "thein3rovert";
          };

        };
      };

      nix = {
        package = lib.mkDefault pkgs.nix;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            #"repl-flake"
          ];
          warn-dirty = false;
        };
        # === Set custom NIX_PATH ===
        nixPath = [ "/etc/nix/path" ];
      };
    };
}
