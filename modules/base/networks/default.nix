{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  string = types.str;
  listOf = types.listOf;
  attributeSetOf = types.attrsOf;
in
{
  # ============================================
  # Network Options
  # ============================================
  options.homelab = {
    baseDomain = mkOption {
      default = "l.thein3rovert.com";
      type = string;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };

    # Primary network interface
    networkInterface = mkOption {
      default = "eth0";
      type = string;
      description = "Primary network interface for homelab services";
    };

    # Host IP addresses for each server
    hosts = mkOption {
      type = attributeSetOf string;
      default = { };
      description = "IP addresses for each homelab host/server";
    };

    # IP Addressing
    ipAddresses = {
      # Host IP addresses
      host = mkOption {
        type = string;
        default = "127.0.0.1";
        description = "Primary host IP address";
      };

      # Gateway
      gateway = mkOption {
        type = string;
        default = "192.168.1.1";
        description = "Network gateway IP address";
      };

      # DNS servers
      dnsServers = mkOption {
        type = listOf string;
        default = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        description = "DNS server addresses";
      };

      # Subnet/CIDR
      subnet = mkOption {
        type = string;
        default = "192.168.1.0/24";
        description = "Network subnet in CIDR notation";
      };

      # Static IP assignments for services
      staticAssignments = mkOption {
        type = attributeSetOf string;
        default = { };
        description = "Static IP assignments for specific services";
      };
    };
  };

  # ============================================
  # Network Configuration
  # ============================================
  config.homelab = {
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
