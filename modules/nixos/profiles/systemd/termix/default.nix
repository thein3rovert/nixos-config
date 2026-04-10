{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixosSetup.services.termix;
in
{
  # Systemd service that runs before the Termix container starts
  # This service creates the necessary directory structure
  config = mkIf cfg.enable {
    systemd.services."setup-termix-data" = {
      description = "Setup Termix data directory";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "setup-termix-data" ''
          set -e
          mkdir -p /var/lib/termix/data
          chmod 755 /var/lib/termix/data
        '';
      };
      wantedBy = [ "podman-termix.service" ];
      before = [ "podman-termix.service" ];
    };
  };
}
