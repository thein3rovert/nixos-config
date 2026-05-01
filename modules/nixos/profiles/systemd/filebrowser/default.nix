{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixosSetup.services.fileshare;
in
{
  # Systemd service that runs before the FileBrowser container starts
  # This service reads the agenix secret and generates the config.yaml file at runtime
  #
  # To verify the service ran successfully:
  #   systemctl status setup-filebrowser-config
  #   cat /var/lib/filebrowser/data/config.yaml
  #
  # The service should show "Active: inactive (dead)" with status=0/SUCCESS
  config = mkIf cfg.enable {
    systemd.services."setup-filebrowser-config" = {
      description = "Setup FileBrowser configuration with secrets";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "setup-filebrowser-config" ''
          set -e

          mkdir -p /var/lib/filebrowser/data/tmp
          mkdir -p /var/lib/filebrowser/files
          chown -R 1000:1000 /var/lib/filebrowser
          PASSWORD=$(cat ${config.age.secrets.fileshare.path})

          cat > /var/lib/filebrowser/data/config.yaml << EOF
          server:
            database: "data/database.db"
            cacheDir: "data/tmp"
            sources:
              - path: "/files"
                name: Home
                config:
                  defaultUserScope: "/"
                  defaultEnabled: true
                  createUserDir: false
            maxArchiveSize: 50
          auth:
            tokenExpirationHours: 2
            methods:
              password:
                enabled: true
                minLength: 5
                signup: false
            adminUsername: thein3rovert
            adminPassword: $PASSWORD
          EOF

          chmod 644 /var/lib/filebrowser/data/config.yaml
        '';
      };
      wantedBy = [ "podman-fileshare.service" ];
      before = [ "podman-fileshare.service" ];
      after = [ "agenix.service" ];
    };
  };
}
