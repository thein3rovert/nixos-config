# ============================================================================
# BASE HOME-MANAGER CONFIG FOR USER: thein3rovert
# ============================================================================
# This file is the shared base config for the `thein3rovert` user across ALL
# systems (both NixOS hosts like `marcus` AND standalone Ubuntu hosts like
# `trikru`).
#
# 📖 See docs: `doc-001 - Home-Manager-Configuration-Architecture.md`
#
# HOW IT'S LOADED:
#   - NixOS hosts:  hosts/<name>/home.nix does:
#                     home-manager.users.thein3rovert = self.homeManagerModules.thein3rovert;
#   - Standalone:   modules/flake/home-manager.nix loads it via
#                     self.homeManagerModules.thein3rovert (which resolves to this file)
#
# ⚠️  INFINITE RECURSION WARNING:
#   Options that home-manager needs during assertion checks (like `stateVersion`,
#   `username`) MUST be set at the unconditional base level below — NEVER inside
#   `mkIf pkgs.stdenv.isLinux { ... }` blocks. Doing so causes infinite recursion
#   in standalone mode because pkgs → _module.args → config → stateVersion → pkgs.
# ============================================================================
{
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
  # Load custom modules (homeSetup.*) from modules/home/
  imports = [ self.homeManagerModules.default ];

  config = mkMerge [
    #--------------------------------------
    # BASE (all systems — Linux + Darwin)
    #--------------------------------------
    {
      home = {
        # ⚠️ REQUIRED options — MUST stay unconditional (see recursion warning above)
        stateVersion = "25.11";
        username = "thein3rovert";

        # Packages available on every system
        packages = with pkgs; [
          curl
          rclone
          htop
        ];
      };

      programs = {
        home-manager.enable = true;
        bash.enable = true;
      };

      xdg.enable = true;

      # Custom modules from modules/home/
      homeSetup.shell.enable = true;

      # homeSetup.programs.agent = {
      #   enable = false;
      #   agentsInput = self.inputs.polis;
      #
      #   opencode = {
      #     enable = true;
      #     agentsInput = self.inputs.polis;
      #     modelOverrides = {
      #       ag-quick-chat = "opencode-go/deepseek-v4";
      #       ag-blog-writer = "anthropic/claude-sonnet-4";
      #     };
      #   };
      # };
    }

    #--------------------------------------
    # DARWIN-ONLY (macOS)
    # Only put things here that ACTUALLY differ on macOS.
    # ⚠️ Do NOT put `stateVersion` or `username` here (see recursion warning).
    #--------------------------------------
    (mkIf pkgs.stdenv.isDarwin {
      home = {
        homeDirectory = "/Users/thein3rovert";
        shellAliases."docker" = "podman";
      };
    })

    #--------------------------------------
    # LINUX-ONLY
    # Only put things here that ACTUALLY differ on Linux.
    # ⚠️ Do NOT put `stateVersion` or `username` here (see recursion warning).
    #--------------------------------------
    (mkIf pkgs.stdenv.isLinux {
      home = {
        homeDirectory = "/home/thein3rovert";
        packages = with pkgs; [ btop ];
      };
    })
  ];
}
