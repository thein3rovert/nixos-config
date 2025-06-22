{ config, ... }:
let
  linkding-credentials = ../../../secrets/linkding-env.age;

in
{
  virtualisation.oci-containers.containers."linkding" = {
    image = "sissbruecker/linkding:latest";
    ports = [ "127.0.0.1:9090:9090" ]; # Local port mapping
    volumes = [ "linkding_data:/etc/linkding/data" ]; # Persistent storage
    environment = {
      LD_DISABLE_BACKGROUND_TASKS = "true";
    };
    environmentFiles = [ config.age.secrets.linkding.path ];
  };

  # Traefik routing configuration
  services.traefik.dynamicConfigOptions.http = {
    services.linkding.loadBalancer.servers = [ { url = "http://localhost:9090/"; } ];
    middlewares = {
      # Add a middleware for linkding headers
      linkding-headers = {
        headers = {
          customRequestHeaders = {
            "Host" = "thein3rovert.dev";
            "X-Forwarded-Proto" = "https";
            "X-Forwarded-Host" = "thein3rovert.dev";
          };
        };
      };
    };

    routers.linkding = {

      rule = "Host(`linkding.thein3rovert.dev`)";
      service = "linkding";
      entryPoints = [ "websecure" ];
      tls = {
        certResolver = "godaddy";
      };
    };
  };
}
