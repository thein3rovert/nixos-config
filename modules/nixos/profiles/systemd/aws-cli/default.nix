{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixosSetup.profiles.systemd.aws-cli;
in
{
  options.nixosSetup.profiles.systemd.aws-cli = {
    enable = mkEnableOption "AWS CLI credentials setup for Garage S3";

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

    region = mkOption {
      type = types.str;
      default = "garage";
      description = "AWS region name";
    };

    profile = mkOption {
      type = types.str;
      default = "garage";
      description = "AWS profile name";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."setup-aws-credentials-${cfg.user}" = {
      description = "Setup AWS CLI credentials for Garage (${cfg.user})";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = pkgs.writeShellScript "setup-aws-creds" ''
          set -e
          mkdir -p /tmp/aws-setup
          cat > /tmp/aws-setup/credentials << EOF
          [${cfg.profile}]
          aws_access_key_id = $(cat ${cfg.accessKeySecretPath})
          aws_secret_access_key = $(cat ${cfg.secretKeySecretPath})
          EOF
          mkdir -p /home/${cfg.user}/.aws
          cp /tmp/aws-setup/credentials /home/${cfg.user}/.aws/credentials
          chmod 600 /home/${cfg.user}/.aws/credentials
          chown ${cfg.user} /home/${cfg.user}/.aws/credentials
          rm -rf /tmp/aws-setup
        '';
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "agenix.service" ];
    };
  };
}
