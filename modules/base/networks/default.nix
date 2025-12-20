{ config, ... }:
{
  homelab = {
    # Primary network interface
    networkInterface = "eth0";

    # Host IP addresses for each server
    hosts = {
      emily = "10.10.10.12";
      finn = "10.10.10.10";
      lexa = "10.10.10.7";
      bellamy = "95.216.216.22";
    };

    # IP Address configurations
    ipAddresses = {
      # Primary host IP (defaults to emily)
      host = config.homelab.hosts.emily;

      # Network gateway
      gateway = "192.168.1.1";

      # DNS servers
      dnsServers = [
        "1.1.1.1"
        "8.8.8.8"
      ];

      # Network subnet
      subnet = "192.168.1.0/24";

      # Static IP assignments for services
      staticAssignments = {
        # Services can reference host IPs used within traefik
        adguard = config.homelab.hosts.finn;
        traefik = config.homelab.hosts.emily;
        linkding = config.homelab.hosts.bellamy;

      # Have their own specific IPs
        nginx = "192.168.1.20";
        pihole = "192.168.1.21";
      };
    };
  };
}
