{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  string = types.str;
  attributeSetOf = types.attrsOf;
in
{
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

  config.homelab = {
    # Host IP addresses for each server
    ipAddresses = {
      localhost = {
        ip = "127.0.0.1";
        tailscaleIp = "";
      };
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
      bellamy = {
        ip = "95.216.216.22";
        tailscaleIp = "100.105.187.63";
      };
      marcus = {
        ip = "10.10.10.13";
        tailscaleIp = "100.68.54.18";
      };
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
      wellsjaha = {
        tailscaleIp = "100.103.139.31";
      };
    };
  };
}
