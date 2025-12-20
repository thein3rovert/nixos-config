{ ... }:
{
  homelab = {
    # Primary network interface
    networkInterface = "eth0";

    # IP Address configurations
    ipAddresses = {
      # Primary host IP
      host = "192.168.1.100";

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
        adguard = "192.168.1.10";
        traefik = "192.168.1.11";
        linkding = "192.168.1.12";
      };
    };
  };
}
