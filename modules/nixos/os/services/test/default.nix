{ config, ... }:
let
  linkding-credentials = ../../../secrets/linkding-env.age;

in
{
  # Change port from 9090 to something else so s3 can make use of it
  virtualisation.oci-containers.containers."linkding" = {
    image = "sissbruecker/linkding:latest";
    ports = [ "10.20.0.1:9090:9090" ]; # Local port mapping
    volumes = [ "linkding_data:/etc/linkding/data" ]; # Persistent storage
    environment = {
      LD_DISABLE_BACKGROUND_TASKS = "true";
    };
    environmentFiles = [ config.age.secrets.linkding.path ];
  };

  # Traefik routing configuration
  services.traefik.dynamicConfigOptions.http = {
    services.linkding.loadBalancer.servers = [ { url = "http://10.20.0.1:9090/"; } ];

    routers.linkding = {

      rule = "Host(`linkding.l.thein3rovert.com`)";
      service = "linkding";
      entryPoints = [ "web" ];
    };
  };
}
