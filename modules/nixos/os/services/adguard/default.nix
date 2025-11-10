{ config, lib, ... }:
{
  options.nixosSetup.services.adguard = {
    enable = lib.mkEnableOption "DNS";
  };

  config = lib.mkIf config.nixosSetup.services.adguard.enable {

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      host = "10.10.10.12";
      # port = 54;
      settings = {
        dns = {
          port = 54;
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
          ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 54 ];
    networking.firewall.allowedUDPPorts = [ 54 ];
  };
}
