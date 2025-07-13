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
        ../../home/features/cli
        ../../home/features/coding
        ../../home/features/desktop
      ];

      home = {
        username = lib.mkDefault "thein3rovert";
        homeDirectory = lib.mkDefault "/home/${config.home.username}";

        packages = with pkgs; [
          btop
          zed-editor
          cowsay
          kitty
          wofi

          # Make sure to move all this to the right config files later
          wlogout
          hyprlock

          blueman

          pavucontrol
          playerctl

          brightnessctl
        ];

        stateVersion = "24.05";
      };

      nix = {
        package = lib.mkDefault pkgs.nix;
        # settings = {
        #   experimental-features = [
        #     "nix-command"
        #     "flakes"
        #   ];
        #   warn-dirty = false;
        # };
      };

      nix = {
        settings = {
          experimental-features = "nix-command flakes"; # === Enable flakes and nix-command ===
          trusted-users = [
            "root"
            "thein3rovert"
          ]; # === Users allowed to run nix commands ===
        };

        # === Enable automatic garbage collection ===
        gc = {
          automatic = true;
          options = "--delete-older-than 30d";
        };

        # # === Enable automatic store optimization ===
        # optimise.automatic = true;

        # === Register all flake inputs as nix registry entries ===
        registry = lib.mapAttrs (_: flake: { inherit flake; }) (
          lib.filterAttrs (_: lib.isType "flake") inputs
        );

        # === Set custom NIX_PATH ===
        nixPath = [ "/etc/nix/path" ];
      };

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      features = {
        cli = {
          zsh.enable = true;
        };
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

    };
}
