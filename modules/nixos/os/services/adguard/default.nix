{ config, lib, ... }:
{
  options.nixosSetup.services.adguard = {
    enable = lib.mkEnableOption "DNS";
  };

  config = lib.mkIf config.nixosSetup.services.adguard.enable {

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      # host = "10.10.10.12";
      # port = 54;
      settings = {
        dns = {
          bind_hosts = [
            "10.10.10.12"
            "127.0.0.1"
          ];
          port = 53;
          upstream_dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };

        filtering = {
          rewrites = [
            {
              domain = "*.l.thein3rovert.com";
              answer = "10.10.10.12";
            }
            /*
              If traefik running on VM:
              - Point adguard to vm ip
              - Create subdomain in host adguard
            */

            # {
            #   domain = "traefik.l.thein3rovert.com";
            #   answer = "10.20.0.1"; # your Traefik host IP
            # }
          ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
