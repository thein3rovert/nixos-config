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
      };
    };
  };
}
