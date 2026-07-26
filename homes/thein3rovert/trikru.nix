# INFO: Standalone home-manager configuration for trikru
# (Ubuntu 22.04 LTS server, Proxmox VM)
#
# Apply with:
#   home-manager switch --flake .#thein3rovert@trikru
#   (or from this repo: nix run .#home-manager -- switch --flake .#thein3rovert@trikru)
{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (lib)
    mkMerge
    mkIf
    ;
in
{
  # Pull shared base (programs: direnv, eza, fzf, tmux, shell, agent)
  imports = [ self.homeManagerModules.default ];

  config = mkMerge [
    # ------------------------------
    # DEFAULT
    # ------------------------------
    {
      home = {
        username = "thein3rovert";
        homeDirectory = "/home/thein3rovert";
        stateVersion = "25.11";

        packages = with pkgs; [
          curl
          rclone
          htop
          btop
        ];
      };

      programs = {
        home-manager.enable = true;
        bash.enable = true;
      };

      xdg.enable = true;

      # ------------------------------
      # CUSTOM MODULES
      # ------------------------------
      homeSetup.shell.enable = true;        # ZSH + Powerlevel10k
      homeSetup.programs.agent.enable = true; # opencode + bun + python3
    }

    # ------------------------------
    # LINUX-SPECIFIC
    # ------------------------------
    (mkIf pkgs.stdenv.isLinux {
      home = {
        username = "thein3rovert";
        homeDirectory = "/home/thein3rovert";
      };
    })
  ];
}