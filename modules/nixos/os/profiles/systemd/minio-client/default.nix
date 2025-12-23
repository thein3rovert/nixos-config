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
  };

  config = mkIf cfg.enable {
    systemd.services."setup-minio-client-${cfg.user}" = {
      description = "Setup MinIO client alias for Garage (${cfg.user})";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = pkgs.writeShellScript "setup-minio-client" ''
          set -e
          ${pkgs.minio-client}/bin/mc alias set ${cfg.alias} ${cfg.endpointUrl} \
            $(cat ${cfg.accessKeySecretPath}) \
            $(cat ${cfg.secretKeySecretPath})
        '';
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "agenix.service" ];
    };
  };
}
