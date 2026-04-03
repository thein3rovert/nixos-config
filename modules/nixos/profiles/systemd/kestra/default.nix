{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixosSetup.services.kestra;
  postgresHost = config.homelab.ipAddresses.emily.tailscaleIp;
  postgresPort = config.homelab.servicePorts.postgresql;
  kestraPort = config.homelab.containerPorts.kestra;
in
{
  # Systemd service that runs before the Kestra container starts
  # This service reads the agenix secret and generates the configuration file at runtime
  #
  # To verify the service ran successfully:
  #   systemctl status setup-kestra-config
  #   cat /var/lib/kestra/config.yaml
  #
  # The service should show "Active: inactive (dead)" with status=0/SUCCESS
  config = mkIf cfg.enable {
    systemd.services."setup-kestra-config" = {
      description = "Setup Kestra configuration with secrets";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "setup-kestra-config" ''
          set -e

          mkdir -p /var/lib/kestra/data
          mkdir -p /tmp/kestra-wd

          PASSWORD=$(cat ${config.age.secrets.kestra-password.path})

          cat > /var/lib/kestra/config.yaml << EOF
          datasources:
            postgres:
              url: jdbc:postgresql://${postgresHost}:${toString postgresPort}/kestra
              driver-class-name: org.postgresql.Driver
              username: kestra
              password: kestra
          kestra:
            server:
              basic-auth:
                enabled: true
                username: thein3rovert@kestra.io
                password: $PASSWORD
            repository:
              type: postgres
            storage:
              type: local
              local:
                base-path: "/app/storage"
            queue:
              type: postgres
            tasks:
              tmp-dir:
                path: /tmp/kestra-wd/tmp
            url: http://localhost:${toString kestraPort}/
          EOF

          chmod 644 /var/lib/kestra/config.yaml
        '';
      };
      wantedBy = [ "podman-kestra.service" ];
      before = [ "podman-kestra.service" ];
      after = [ "agenix.service" ];
    };
  };
}
