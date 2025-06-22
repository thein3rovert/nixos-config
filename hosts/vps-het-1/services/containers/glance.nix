{
  pkgs,
  lib,
  config,
  ...
}:

{
  virtualisation.oci-containers.containers."glance" = {
    image = "glanceapp/glance";
    volumes = [
      "/home/thein3rovert-cloud/.config/glance/config:/app/config"
      "/etc/timezone:/etc/timezone:ro" # Ensures container timezone sync.
      "/etc/localtime:/etc/localtime:ro"
      "/home/thein3rovert-cloud/.config/glance/config/assets:/app/assets"
    ];
    ports = [ "127.0.0.1:8280:8080" ];
    # log-driver = "journald";
    # extraOptions = [ "--network-alias=glance" "--network=glance_default" ];
  };

  # === Traefik routing configuration ===
  services.traefik.dynamicConfigOptions.http = {
    services.glance.loadBalancer.servers = [ { url = "http://127.0.0.1:8280/"; } ];

    # === Routes ===
    routers.glance = {
      rule = "Host(`glance.thein3rovert.dev`)";
      service = "glance";
      entryPoints = [ "websecure" ];
      tls = {
        certResolver = "godaddy";
      };
    };
  };

}
