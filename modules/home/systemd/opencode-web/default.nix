# ==============================================================================
# OPENCODE WEB SERVER - HOME-MANAGER SYSTEMD USER SERVICE
# ==============================================================================
# Runs opencode web interface as a systemd user service.
# This is for standalone home-manager configs (not NixOS integration).
#
# USAGE:
#   1. Enable in your home-manager config (e.g., homes/thein3rovert/trikru.nix):
#      homeSetup.systemd.opencode-web = {
#        enable = true;
#        port = 3000;
#        hostname = "0.0.0.0";
#      };
#
#   2. Deploy:
#      home-manager switch --flake .#thein3rovert@trikru
#
#   3. Manage:
#      systemctl --user status opencode-web
#      journalctl --user -u opencode-web -f
# ==============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.homeSetup.systemd.opencode-web;
in
{
  options.homeSetup.systemd.opencode-web = {
    enable = mkEnableOption "Opencode Web Server";

    port = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Port for opencode web server (null = use opencode default)";
    };

    hostname = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Hostname/address for opencode web server to bind to";
    };

    logLevel = mkOption {
      type = types.str;
      default = "WARN";
      description = "Log level (DEBUG, INFO, WARN, ERROR)";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.opencode-web = {
      Unit = {
        Description = "Opencode Web Interface";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.opencode}/bin/opencode web --hostname ${cfg.hostname}${lib.optionalString (cfg.port != null) " --port ${toString cfg.port}"} --log-level ${cfg.logLevel}";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = [
          "PATH=${pkgs.xdg-utils}/bin:/home/thein3rovert/.nix-profile/bin:/run/current-system/sw/bin:/usr/bin:/bin"
        ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
