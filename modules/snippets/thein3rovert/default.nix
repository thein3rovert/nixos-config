{ lib, config, ... }:
let
  baseDomain = "thein3rovert.dev";
  cfg = config.homelab;
in
{
  options.snippets.thein3rovert.networkMap = lib.mkOption {
    type = lib.types.attrs;
    description = "Hostnames, ports, and vHosts for thein3rovert.dev services.";
    default = {

      traefik = {
        hostName = "bellamy";
        port = cfg.servicePorts.traefik;
        vHost = "traefik.${baseDomain}";
      };

      jotty = {
        hostName = "Bellamy";
        port = cfg.containerPorts.jotty;
        vHost = "jotty.${baseDomain}";
      };

      freshrss = {
        hostName = "Bellamy";
        port = cfg.containerPorts.freshrss;
        vHost = "freshrss.${baseDomain}";
      };

      uptime-kuma = {
        hostName = "Bellamy";
        port = cfg.containerPorts.uptime-kuma;
        vHost = "uptime-kuma.${baseDomain}";
      };
      s3 =
        let
        in
        {
          hostName = "Bellamy";
          port = cfg.servicePorts.minio;
          # port = [
          #   3007
          #   3008
          # ];
          vHost = [
            "minio-console.${baseDomain}"
            "minio.${baseDomain}"
          ];
        };
      garage-api = {
        hostName = "Bellamy";
        port = cfg.servicePorts.garage-api;
        vHost = "s3.${baseDomain}";
      };
    };
  };
}
