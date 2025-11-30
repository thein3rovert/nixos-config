{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.nixosSetup.programs.incus;
in
{
  options.nixosSetup.programs.incus.enable = lib.mkEnableOption "Inncus Virtual Machine Manager";

  config = lib.mkIf cfg.enable {

    virtualisation = {
      incus = {
        enable = true;

        preseed = {

          networks = [
            {
              config = {
                "ipv4.address" = "10.20.0.3/24";
                "ipv4.nat" = "true";

                # Disable Incus DNS completely
                "dns.mode" = "none";

                # Keep DHCP (containers still get IPs)
                "ipv4.dhcp" = "true";
              };

              name = "incusbr0";
              type = "bridge";
            }
          ];

          profiles = [
            {
              devices = {
                eth0 = {
                  name = "eth0";
                  network = "incusbr0";
                  type = "nic";
                };
                root = {
                  path = "/";
                  pool = "default";
                  size = "20GiB";
                  type = "disk";
                };
              };
              name = "default";
            }
          ];

          storage_pools = [
            {
              config = {
                source = "/var/lib/incus/storage-pools/default";
              };
              driver = "dir";
              name = "default";
            }
          ];
        };
      };
    };

    # Incus Networking Base
    networking = {
      nftables = {
        enable = true;
      };
      firewall.trustedInterfaces = [ "incusbr0" ];
    };

    # Add Inucus to extra group
    # TODO: Use homelab user as base users or add incus-admin to homelab base
    users.users.thein3rovert.extraGroups = [ "incus-admin" ];

  };
}
