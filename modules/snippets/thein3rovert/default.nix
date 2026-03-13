{ lib, config, ... }:
let
  cfg = config.homelab;
  baseDomain = cfg.domain.prod;
in
{
  options.snippets.thein3rovert.networkMap = lib.mkOption {
    type = lib.types.attrs;
    description = "Hostnames, ports, and vHosts for thein3rovert.dev services.";
    default = {

      glance = {
        hostName = "Bellamy";
        port = cfg.servicePorts.glance;
        vHost = "glance.${baseDomain}";
      };

      tailscale = {
        hostName = "Bellamy";
        port = cfg.servicePorts.tailscale;
        vHost = "tailscale.${baseDomain}";
      };

      traefik = {
        hostName = "Bellamy";
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
          s3-port = cfg.servicePorts.minio;
        in
        {
          hostName = "Bellamy";
          port = if lib.isList s3-port then s3-port else [ s3-port ];
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
      forgejo = {
        hostName = "Bellamy";
        port = cfg.servicePorts.forgejo;
        sshVHost = "ssh.${baseDomain}";
        vHost = "code.${baseDomain}";
      };
    };
  };
}
