# INFO: Standalone home-manager configuration for trikru
# (Ubuntu 22.04 LTS server, Proxmox VM)
#
# Apply with:
#   home-manager switch --flake .#thein3rovert@trikru
#   (or from this repo: nix run .#home-manager -- switch --flake .#thein3rovert@trikru)
{
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
  /*
    This can be found in flake/home-manager modules
    Contains the base home manager modules in the
    modules folder, this makes sure we can enabled
    configured modules by setting them to true
  */
  imports = [ self.homeManagerModules.default ];

  config = mkMerge [
    # ------------------------------
    # DEFAULT
    # ------------------------------

    /*
      Merge default (base) home manager coonfig for
      trikru
    */
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
        # bash.enable = true;
        zsh.enable = true;
      };
      xdg.enable = true;

      # ------------------------------
      # CUSTOM MODULES
      # ------------------------------
      /*
        Merge default (base) home manager coonfig for
        trikru
      */
      homeSetup.shell.enable = true; # ZSH + Powerlevel10k
      # TODO: This to be enabled when my agent
      # lib is complete (Mrcus and Trikru needs it first)
      homeSetup.programs.agent.enable = false; # opencode + bun + python3
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
