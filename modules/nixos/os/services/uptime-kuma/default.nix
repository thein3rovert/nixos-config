{
  config,
  lib,
  ...
}:
let

  if-uptime-kuma-enable = lib.mkIf config.nixosSetup.services.uptime-kuma.enable;
  imageName = "louislam/uptime-kuma";
  host = "127.0.0.1";
  port = 8380;
  dataVolume = "uptime-kuma_data";
in
{
  options.nixosSetup.services.uptime-kuma = {
    enable = lib.mkEnableOption "Monitoring";
  };

  config = if-uptime-kuma-enable {

    myContainers.traefik = {
      enable = true;
      defaultEntryPoints = [ "websecure" ];
      defaultCertResolver = "godaddy";
    };
    myContainers = {
      enable = true;
      containers = {
        uptime-kuma = {
          image = "${imageName}";
          ports = [ "${host}:${toString port}:3001" ];
          volumes = [
            "${dataVolume}:/app/data"

          ];
          traefik = {
            enable = true;
            url = "http://localhost:8380/";
            rule = "Host(`uptime-kuma.thein3rovert.dev`)";
          };

        };
      };
    };
  };
}
