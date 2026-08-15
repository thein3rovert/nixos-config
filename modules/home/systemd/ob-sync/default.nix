# ==============================================================================
# OBSIDIAN HEADLESS SYNC SYSTEMD USER SERVICE (HOME-MANAGER)
# ==============================================================================
# Runs obsidian-headless in continuous sync mode as a systemd user service.
# This is for standalone home-manager configs (not NixOS integration).
# 
# USAGE:
#   1. Enable in your home-manager config (e.g., homes/thein3rovert/trikru.nix):
#      homeSetup.systemd.ob-sync = {
#        enable = true;
#        vaultPath = "%h/vault";  # %h = home directory
#      };
#
#   2. Setup your vault first (one-time):
#      ob login
#      cd ~/vault
#      ob sync-setup --vault "My Vault Name"
#
#   3. Deploy:
#      home-manager switch --flake .#thein3rovert@trikru
#
#   4. Manage the service:
#      systemctl --user status ob-sync
#      systemctl --user start ob-sync
#      systemctl --user stop ob-sync
#      systemctl --user restart ob-sync
#      journalctl --user -u ob-sync -f  # View logs
#
# NOTES:
#   - Service runs as your user (not root)
#   - Auto-restarts on failure (30s delay)
#   - Requires network connection
#   - Vault must be setup with `ob sync-setup` before enabling service
# ==============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.homeSetup.systemd.ob-sync;
in
{
  options.homeSetup.systemd.ob-sync = {
    enable = mkEnableOption "Obsidian Headless Sync Service";

    vaultPath = mkOption {
      type = types.str;
      default = "%h/vault";
      description = ''
        Path to the Obsidian vault to sync. Use %h for home directory.
        Example: "%h/Documents/obsidian-vault" or "/home/user/vault"
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.ob-sync = {
      Unit = {
        Description = "Obsidian Headless Continuous Sync";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        WorkingDirectory = cfg.vaultPath;
        ExecStart = "${pkgs.obsidian-headless}/bin/ob sync --continuous";
        Restart = "always";
        RestartSec = 10;
        TimeoutStopSec = 5;
        KillMode = "mixed";
        KillSignal = "SIGTERM";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
