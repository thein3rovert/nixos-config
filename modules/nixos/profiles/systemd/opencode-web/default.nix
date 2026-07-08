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
  };

  config = mkIf cfg.enable {
    systemd.user.services.opencode-web = {
      description = "Opencode Web Server";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "%h/.npm-global/bin/opencode web";
        Restart = "always";
        RestartSec = 10;
      };
    };
  };
}
