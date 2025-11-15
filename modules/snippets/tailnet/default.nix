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
in
{
  options.snippets.tailnet = {
    # Create local network map and main
    name = createOption {
      default = "tailf87228.ts.net";
      description = "Tailnet name";
      type = string;
    };

    tailnetNetworkMap = createOption {
      type = list;
      description = "Hostnames, ports, and vHosts for ${config.snippet.tailnetNetworkMap.name} services.";

      # TODO: Add tailnet services to DNS

      # default = {
      #   linkding = {
      #     hostName = "wellsjaha";
      #     port = "9090";
      #     vHost = "linkding.${config.myDns.networkMap.name}";
      #   };
      #   adguard = {
      #     hostName = "${emily}";
      #     port = 3000;
      #     vHost = "adguard.${config.myDns.networkMap.name}";
      #   };
      #   n8n = {
      #     hostName = "${emily}";
      #     port = 5678;
      #     vHost = "n8n.${config.myDns.networkMap.name}";
      #   };
      #   traefik = {
      #     hostName = "${emily}";
      #     port = 5678;
      #     vHost = "traefik.${config.myDns.networkMap.name}";
      #   };
      # };
    };
  };
}
