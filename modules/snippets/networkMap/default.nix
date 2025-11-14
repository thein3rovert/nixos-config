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
  options.myDns.networkMap = {
    # Create local network map and main
    name = createOption {
      default = "l.thein3rovert.com";
      description = "Local DNS";
      type = string;
    };

    localNetworkMap = createOption {
      type = list;
      description = "Hostnames, ports, and vHosts for ${config.myDns.networkMap.name} services.";

      default = {
        linkding = {
          hostName = "bellamy";
          port = 9090;
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
      };
    };
  };
}
