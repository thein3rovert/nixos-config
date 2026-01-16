{ lib, config, ... }:
let
  baseDomain = "thein3rovert.dev";
  cfg = config.homelab;
in
{
  options.snippets.thein3rovert.networkMap = lib.mkOption {
    type = lib.types.attrs;
    description = "Hostnames, ports, and vHosts for cute.haus services.";
    default = {

      traefik = {
        hostName = "bellamy";
        port = 80;
        vHost = "traefik.${baseDomain}";
      };

      jotty = {
        hostName = "Bellamy";
        port = 8382;
        vHost = "jotty.${baseDomain}";
      };

      freshrss = {
        hostName = "Bellamy";
        port = 8083;
        vHost = "freshrss.${baseDomain}";
      };

      uptime-kuma = {
        hostName = "Bellamy";
        port = 8380;
        vHost = "uptime-kuma.${baseDomain}";
      };
      s3 = {
        hostName = "Bellamy";
        port = [
          3007
          3008
        ];
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
