{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  string = types.str;
  attributeSetOf = types.attrsOf;
in
{
  # ============================================
  # IP Addresses Options
  # ============================================
  options.homelab = {
    ipAddresses = mkOption {
      type = attributeSetOf (
        types.submodule {
          options = {
            ip = mkOption {
              type = string;
              description = "Local network IP address";
              default = "127.0.0.1";
            };
            tailscaleIp = mkOption {
              type = string;
              default = "";
              description = "Tailscale IP address";
            };
          };
        }
      );
      default = { };
      description = "IP addresses for each homelab host/server";
    };
  };

  # ============================================
  # IP Addresses Configuration
  #
  # /*
  #  Local Services: Services running on the main host (127.0.0.1)
  #  LXC Containers: Services running in LXC containers (10.10.10.x)
  #  VM Services: Services running in virtual machines (10.20.0.x)
  #  Tailscale Services: Services accessible via Tailscale VPN (100.x.x.x)
  #  Production VPS: Services running on the production VPS (bellamy)
  # */
  #
  # ============================================
  config.homelab = {
    ipAddresses = {
      # ============================================
      # Local Services
      # ============================================
      localhost = {
        ip = "127.0.0.1";
        tailscaleIp = "";
      };

      # ============================================
      # LXC Container Hosts
      # ============================================
      emily = {
        ip = "10.10.10.12";
        tailscaleIp = "100.105.217.77";
      };
      finn = {
        ip = "10.10.10.10";
        tailscaleIp = "100.91.36.84";
      };
      lexa = {
        ip = "10.10.10.7";
        tailscaleIp = "100.88.29.64";
      };
      marcus = {
        ip = "10.10.10.11";
        tailscaleIp = "100.94.20.21";
      };

      # ============================================
      # Production VPS
      # ============================================
      bellamy = {
        ip = "95.216.216.22";
        tailscaleIp = "100.105.187.63";
      };

      # ============================================
      # VM Services
      # ============================================
      wellsjaha = {
        ip = "10.20.0.1";
        tailscaleIp = "100.103.139.31";
      };
       k3s-server = {
                 ip = "10.10.20.100";
                 tailscaleIp = "100.85.190.19";
               };
      # ============================================
      # Tailscale Only (no local IP)
      # ============================================
      nixos-runner = {
        tailscaleIp = "100.111.90.52";
      };
      node-0 = {
        tailscaleIp = "100.72.97.99";
      };
      node-1 = {
        tailscaleIp = "100.90.77.80";
      };
      server = {
        tailscaleIp = "100.68.106.100";
      };
      ipad = {
        tailscaleIp = "100.77.165.98";
      };
      iphone = {
        tailscaleIp = "100.111.254.114";
      };
      ubuntu-ct-01 = {
        tailscaleIp = "100.110.115.126";
      };

      # ============================================
      # Podman Bridge
      # ============================================
      podman0 = {
        ip = "10.88.0.0";
        tailscaleIp = "";
      };
      podman-web = {
        ip = "10.89.0.0";
        tailscaleIp = "";
      };
    };
  };
}
