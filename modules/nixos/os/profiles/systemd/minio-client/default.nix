{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixosSetup.profiles.systemd.minio-client;
in
{
  options.nixosSetup.profiles.systemd.minio-client = {
    enable = mkEnableOption "MinIO client alias setup for Garage S3";

    user = mkOption {
      type = types.str;
      description = "Username for the credentials";
      example = "thein3rovert";
    };

    accessKeySecretPath = mkOption {
      type = types.str;
      description = "Path to the agenix secret containing the access key";
    };

    secretKeySecretPath = mkOption {
      type = types.str;
      description = "Path to the agenix secret containing the secret key";
    };

    endpointUrl = mkOption {
      type = types.str;
      default = "http://localhost:3900";
      description = "Garage S3 endpoint URL";
    };

    alias = mkOption {
      type = types.str;
      default = "garage";
      description = "MinIO client alias name";
    };

    dependsOnGarage = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to wait for garage.service to be running before setting up the alias";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."setup-minio-client-${cfg.user}" = {
      description = "Setup MinIO client alias for Garage (${cfg.user})";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = pkgs.writeShellScript "setup-minio-client" ''
          set -e

          ACCESS_KEY=$(cat ${cfg.accessKeySecretPath})
          SECRET_KEY=$(cat ${cfg.secretKeySecretPath})

          # Remove existing alias if it exists
          if ${pkgs.minio-client}/bin/mc alias list ${cfg.alias} &>/dev/null; then
            echo "Removing existing alias '${cfg.alias}'..."
            ${pkgs.minio-client}/bin/mc alias remove ${cfg.alias} || true
          fi

          # Set the alias (this will attempt to connect but we'll handle failures)
          echo "Setting MinIO client alias '${cfg.alias}' for ${cfg.endpointUrl}..."
          if ${pkgs.minio-client}/bin/mc alias set ${cfg.alias} ${cfg.endpointUrl} \
            "$ACCESS_KEY" "$SECRET_KEY" 2>&1 | tee /tmp/mc-setup.log; then
            echo "✓ MinIO client alias '${cfg.alias}' configured and validated successfully"
          else
            # Check if it's just a connection error
            if grep -q "connection refused\|timeout\|dial tcp" /tmp/mc-setup.log; then
              echo "⚠ MinIO client alias '${cfg.alias}' configured but endpoint is not reachable yet"
              echo "  The alias will work once ${cfg.endpointUrl} is available"
              rm -f /tmp/mc-setup.log
              exit 0
            else
              echo "✗ Failed to configure MinIO client alias"
              cat /tmp/mc-setup.log
              rm -f /tmp/mc-setup.log
              exit 1
            fi
          fi
          rm -f /tmp/mc-setup.log
        '';
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "agenix.service" ] ++ optionals cfg.dependsOnGarage [ "garage.service" ];
    };
  };
}
