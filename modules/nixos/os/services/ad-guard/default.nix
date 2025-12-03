{ config, lib, ... }:
{
  options.nixosSetup.services.ad-guard = {
    enable = lib.mkEnableOption "DNS for lxc container";
  };

  config = lib.mkIf config.nixosSetup.services.ad-guard.enable {

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      settings = {
        dns = {
          bind_hosts = [
            "10.135.108.203"
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
              # After nixos yarara update, rewrite disable by default
              enabled = true;
              domain = "*.l.thein3rovert.com";
              answer = "10.135.108.203";
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
    #
    # networking.firewall.allowedTCPPorts = [ 53 ];
    # networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
