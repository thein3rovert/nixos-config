{ lib, ... }:
let
  baseDomain = "thein3rovert.dev";
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

    };
  };
}
