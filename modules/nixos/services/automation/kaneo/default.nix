{
  pkgs,
  lib,
  config,
  ...
}:
let
  if-kaneo-enable = lib.mkIf config.nixosSetup.services.kaneo.enable;

  imageName = "ghcr.io/usekaneo/kaneo:${imageTag}";
  imageTag = "latest";
  port = config.homelab.containerPort.kaneo;
  postgresPort = config.homelab.servicePorts.postgresql;

in
{

  options.nixosSetup.services.kaneo = {
    enable = lib.mkEnableOption "Kaneo Project Management Software";
  };

  config = if-kaneo-enable {
    virtualisation.oci-containers.containers.kaneo = {
      image = "${imageName}";
      ports = [ "${toString port}:5173" ];
      environment = {
        DATABASE_URL = "postgresql://kaneo:kaneo@host.containers.internal:${toString postgresPort}/kaneo";
        KANEO_CLIENT_URL = "http://localhost:${toString port}";
        AUTH_SECRET = ""; # TODO: Generate with: openssl rand -hex 32
      };
      environmentFile = [ config.age.secrets.kaneo-auth.path ];

      dependsOn = [ "postgres" ];
      restart = "unless-stopped";
    };
  };
}
