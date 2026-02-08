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

    # ============================================
    # Ports Configuration
    # ============================================
    containerPorts = mkOption {
      type = types.attrsOf (types.either types.int (types.listOf types.int));
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };

    servicePorts = mkOption {
      type = types.attrsOf (types.either types.int (types.listOf types.int));
      default = { };
      description = "Ports used by Nixos Podman services";
    };

    customPorts = mkOption {
      type = types.attrsOf types.int;
      default = { };
      description = "Ports used by custom Services and Applications";
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
      emilyts = "100.105.217.77";
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
        forgejo = config.homelab.hosts.emilyts;
        # Have their own specific IPs
        nginx = "192.168.1.20";
        pihole = "192.168.1.21";
      };
    };

    # ============================================
    # Ports Configuration
    # ============================================
    containerPorts = {
      linkding = 5860;
      zerobyte = 4096;
      uptime-kuma = 8380;
      freshrss = 8083;
      jotty = 8382;
    };

    servicePorts = {
      traefik = 80;
      adguard = 53;
      ssh = 22;
      ssh-forgejo = 2222;
      garage-api = 3900;
      minio = [
        3007
        3008
      ];
      postgresql = 5432;
    };

    customPorts = {
      ipam = 5050;
      api = 4873;
    };
  };
}
