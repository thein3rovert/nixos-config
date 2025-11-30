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
  options.nixosSetup.programs.incus.enable = lib.mkEnableOption ''
      incusd, a daemon that manages containers and virtual machines.

    Users in the "incus-admin" group can interact with
    the daemon (e.g. to start or stop containers) using the
    {command}`incus` command line tool, among others.
    Users in the "incus" group can also interact with
    the daemon, but with lower permissions
    (i.e. administrative operations are forbidden).
  '';

  config = lib.mkIf cfg.enable {

    virtualisation = {
      incus = {
        enable = true;
        ui.enable = true;
        preseed = {

          networks = [
            {
              config = {
                "ipv4.address" = "10.20.0.1/24";
                "ipv4.nat" = "true";

                # Disable Incus DNS completely
                "dns.mode" = "none";
                # "dns.nameservers" = [ "10.10.10.12" ];
                # Forward DNS queries to your AdGuard Home
                # "raw.dnsmasq" = "server=10.10.10.12";
                "raw.dnsmasq" = "dhcp-option=6,10.10.10.12";
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
              config = {
                "user.user-data" = ''
                  #cloud-config
                  network:
                    version: 2
                    ethernets:
                      eth0:
                        dhcp4: true
                        nameservers:
                          addresses:
                            - 10.10.10.12

                '';
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
      # firewall.interfaces.incusbr0.allowedTCPPorts = [
      #   53
      #   67
      # ];
      # firewall.interfaces.incusbr0.allowedUDPPorts = [
      #   53
      #   67
      # ];
    };

    # Add Inucus to extra group
    # TODO: Use homelab user as base users or add incus-admin to homelab base
    users.users.thein3rovert.extraGroups = [ "incus-admin" ];

  };
}
