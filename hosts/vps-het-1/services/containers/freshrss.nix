{ config, ... }:
{
  # === Container Configurations ===
  virtualisation.oci-containers.containers."freshrss" = {
    image = "freshrss/freshrss:latest";
    ports = [ "127.0.0.1:8083:80" ]; # Local port mapping
    volumes = [
      "freshrss_data:/etc/freshrss/data" # Persistent storage
      "freshrss_data:/var/www/FreshRSS/data"
      "freshrss_extensions:/var/www/FreshRSS/extensions"
    ];
    environment = {
      TZ = "Europe/London";
      CRON_MIN = "2,32";
      FRESHRSS_ENV = "development";

      OIDC_ENABLED = "0";
    };

    # === Env File Path ===
    # environmentFiles = [ config.age.secrets.freshrss.path ];

  };

  # === Traefik routing configuration ===
  services.traefik.dynamicConfigOptions.http = {
    services.freshrss.loadBalancer.servers = [ { url = "http://localhost:8083/"; } ];
    middlewares = {
      # Add a middleware for linkding headers
      # freshrss-headers = {
      #   headers = {
      #     customRequestHeaders = {
      #       "Host" = "thein3rovert.dev";
      #       "X-Forwarded-Proto" = "https";
      #       "X-Forwarded-Host" = "thein3rovert.dev";
      #     };
      #   };
      # };
    };

    # === Routes ===
    routers.freshrss = {
      rule = "Host(`freshrss.thein3rovert.dev`)";
      service = "freshrss";
      entryPoints = [ "websecure" ];
      tls = {
        certResolver = "godaddy";
      };
    };
  };
}
