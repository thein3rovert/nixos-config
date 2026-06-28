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
  port = config.homelab.containerPorts.kaneo;
  postgresPort = config.homelab.servicePorts.postgresql;
  tailscaleIp = config.homelab.ipAddresses.emily.tailscaleIp;

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
        # KANEO_CLIENT_URL = "http://${tailscaleIp}:${toString port}";
        KANEO_CLIENT_URL = "http://kaneo.l.thein3rovert.com";
        AUTH_URL = "http://kaneo.l.thein3rovert.com/api";
        DEVICE_AUTH_CLIENT_IDS = "kaneo-cli,kaneo-mcp";
      };
      environmentFiles = [ config.age.secrets.kaneo-auth-secret.path ];
      autoStart = true;
    };
  };
}
