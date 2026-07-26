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
  # Stable symlink: always points to current zsh via the home-manager profile
  zshPath = "${config.home.homeDirectory}/.nix-profile/bin/zsh";
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
          # info: Not sure but i think this comes with the default
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
      homeSetup.shell.enable = true; # ZSH + Powerlevel10k
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

      # ------------------------------
      # DECLARATIVE LOGIN SHELL
      # ------------------------------
      # On non-NixOS hosts, /etc/passwd + /etc/shells are not managed by
      # home-manager. This activation script makes the login shell follow
      # the zsh that home-manager installs (idempotent — silent when correct).
      # Requires NOPASSWD sudo for the user (set up at bootstrap).
      home.activation.ensureZshLoginShell =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run bash -c '
            ZSH=${zshPath}
            # Register with /etc/shells if missing
            if ! grep -qx "$ZSH" /etc/shells 2>/dev/null; then
              exec sudo -n sh -c "echo $ZSH >> /etc/shells"
            fi
            # chsh if current shell differs
            CURRENT=$(getent passwd thein3rovert | cut -d: -f7)
            if [ "$CURRENT" != "$ZSH" ]; then
              exec sudo -n chsh -s "$ZSH" thein3rovert
            fi
          '
        '';
    })
  ];
}
