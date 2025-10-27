{ lib, config, ... }:
let
  if-freshrss-enabled = lib.mkIf config.nixosSetup.containers.freshrss.enable;

  # TODO: Common attribute name should be
  # moved to base as shared options
  imageName = "freshrss/freshrss";
  imageTag = "latest";
  host = "127.0.0.1";
  port = 8083;

  dataVolume = "freshrss_data";
  extensionsVolume = "freshrss_extensions";
in
{
  options.nixosSetup.containers.freshrss = {
    enable = lib.mkEnableOption "Enable Freshrss Services";
  };
  config = if-freshrss-enabled {
    myContainers = {
      enable = true;
      containers = {
        freshrss = {
          image = "${imageName}:${imageTag}";
          ports = [ "${host}:${toString port}:80" ];
          volumes = [
            "${dataVolume}:/etc/freshrss/data"
            "${dataVolume}:/var/www/FreshRSS/data"
            "${extensionsVolume}:/var/www/FreshRSS/extensions"
          ];
          environment = {
            TZ = "Europe/London";
            CRON_MIN = "2,32";
            FRESHRSS_ENV = "development";
            OIDC_ENABLED = "0";
          };
          environmentFiles = [ config.age.secrets.freshrss.path ];
        };
      };
    };

    # Traefik dynamic configuration
    services.traefik.dynamicConfigOptions.http = {
      services.freshrss.loadBalancer.servers = [
        { url = "http://localhost:8083/"; }
      ];

      routers.freshrss = {
        rule = "Host(`freshrss.thein3rovert.dev`)";
        service = "freshrss";
        entryPoints = [ "websecure" ];
        tls = {
          certResolver = "godaddy";
        };
      };
    };
  };
}
