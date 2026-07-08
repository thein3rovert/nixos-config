{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixosSetup.services.opencode-web;
in
{
  options.nixosSetup.services.opencode-web = {
    enable = mkEnableOption "Opencode Web Server";
    
    port = mkOption {
      type = types.int;
      default = 4097;
      description = "Port for opencode web server";
    };

    hostname = mkOption {
      type = types.str;
      default = "10.88.0.1";
      description = ''
        Hostname/address for opencode web server to bind to. Defaults to
        podman bridge (10.88.0.1) to allow containers to reach it via
        host.containers.internal without exposing it to the whole LAN, or
        set to "0.0.0.0" to listen on all interfaces.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.opencode-web = {
      description = "Opencode Web Server";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "%h/.npm-global/bin/opencode web --port ${toString cfg.port} --hostname ${cfg.hostname}";
        Restart = "always";
        RestartSec = 10;
      };
      path = [ pkgs.xdg-utils ];
    };
  };
}
