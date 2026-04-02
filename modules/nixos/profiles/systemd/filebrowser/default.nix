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
  config = mkIf cfg.enable {
    systemd.services."setup-filebrowser-config" = {
      description = "Setup FileBrowser configuration with secrets";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "setup-filebrowser-config" ''
          set -e

          mkdir -p /var/lib/filebrowser/data/tmp
          mkdir -p /var/lib/filebrowser/files

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
