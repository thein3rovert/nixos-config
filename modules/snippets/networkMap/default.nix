{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  createOption = mkOption;
  string = types.str;
  list = types.attrs;
  emily = "nixos";

  homelab = config.homelab;
in
{
  options.myDns.networkMap = {
    # Create local network map and main
    name = createOption {
      default = "${homelab.baseDomain}";
      description = "Local DNS";
      type = string;
    };

    localNetworkMap = createOption {
      type = list;
      description = "Hostnames, ports, and vHosts for ${config.myDns.networkMap.name} services.";

      default = {
        linkding = {
          hostName = "wellsjaha";
          port = "9090";
          vHost = "linkding.${config.myDns.networkMap.name}";
        };
        adguard = {
          hostName = "${emily}";
          port = 3000;
          vHost = "adguard.${config.myDns.networkMap.name}";
        };
        n8n = {
          hostName = "${emily}";
          port = 5678;
          vHost = "n8n.${config.myDns.networkMap.name}";
        };

        incus = {
          hostName = "${emily}";
          port = 8443;
          vHost = "incus.${config.myDns.networkMap.name}";
        };

        traefik = {
          hostName = "${emily}";
          port = 5678;
          vHost = "traefik.${config.myDns.networkMap.name}";
        };

        ## Container network map
        ad-guard = {
          hostName = "lexa";
          port = 3000;
          vHost = "ad-guard.${config.myDns.networkMap.name}";
        };
        fossflow = {
          hostName = "${emily}";
          port = 8087;
          vHost = "fossflow.${config.myDns.networkMap.name}";
        };
        zerobyte = {
          hostName = "${emily}";
          port = 8087;
          vHost = "zerobyte.${config.myDns.networkMap.name}";
        };

        # MONITORING
        grafana = {
          hostName = "${emily}";
          port = 3010;
          vHost = "grafana.${config.myDns.networkMap.name}";
        };
        prometheus = {
          hostName = "${emily}";
          port = 3020;
          vHost = "prometheus.${config.myDns.networkMap.name}";
        };
        loki = {
          hostName = "${emily}";
          port = 3030;
          vHost = "loki.${config.myDns.networkMap.name}";
        };
        forgejo = {
          hostName = "runner";
          port = 3002;
          vHost = "runner.${config.myDns.networkMap.name}";
        };
        vault = {
          hostName = "runner";
          port = 8200;
          vHost = "vault.${config.myDns.networkMap.name}";
        };
        garage-webui = {
          hostName = "${emily}";
          port = 3909;
          vHost = "s3-web.${config.myDns.networkMap.name}";
        };
      };
    };
  };
}
