{
  config,
  lib,
  pkgs,
  ...
}:
let
  # WARNING: When ever the config is broken, it requires we restart the preseed manually
  # using the command systemctl start incus-preseed.services.
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
    virtualisation.incus = {
      enable = true;
      ui.enable = true;

      preseed = {
        config = { };
        networks = [
          {
            name = "incusbr0";
            description = "Default: Internal/NATted bridge";
            type = "bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv4.nat" = "true";

              "ipv4.firewall" = "false";
              "ipv6.address" = "auto";
              "ipv6.nat" = "true";
              "ipv6.firewall" = "false";
            };
          }
        ];
        ## Storage_pools
        storage_pools = [
          {
            name = "default";

            description = "Default Incus Storage";
            driver = "dir";
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            description = "Default Incus Profile";
            devices = {
              root = {
                type = "disk";
                pool = "default";
                path = "/";
              };
            };
          }
        ];
      };

    };

    # I think the incus nixos config is just no applying
    # maybe preseed is broken
    # preseed = {
    #   networks = [
    #     {
    #       name = "incusbr0";
    #       type = "bridge";
    #       description = "Internal/NATted bridge";
    #
    #       config = {
    #         "ipv4.address" = "auto";
    #         "ipv4.nat" = "true";
    #         "ipv4.firewall" = "false";
    #         "ipv6.address" = "auto";
    #         "ipv6.nat" = "true";
    #         "ipv6.firewall" = "false";
    #       };
    #     }
    #   ];
    #
    #   profiles = [
    #     {
    #       name = "thein3rovert";
    #       description = "thein3rovert Incus Profile";
    #
    #       devices = {
    #         eth0 = {
    #           type = "nic";
    #           network = "incusbr0";
    #           name = "eth0";
    #         };
    #
    #         root = {
    #           type = "disk";
    #           path = "/";
    #           pool = "default";
    #         };
    #       };
    #     }
    #     {
    #       devices = {
    #         eth0 = {
    #           name = "eth0";
    #           network = "incusbr0";
    #           type = "nic";
    #         };
    #         root = {
    #           path = "/";
    #           pool = "default";
    #           size = "35GiB";
    #           type = "disk";
    #         };
    #       };
    #       name = "default";
    #       description = "Default Incus Profile Nixos";
    #     }
    #   ];
    # };
    #

    #     networks = [
    #       {
    #         config = {
    #
    #           config = {
    #             "ipv4.address" = "auto";
    #             "ipv4.nat" = "true";
    #             "ipv4.firewall" = "false";
    #             "ipv6.address" = "auto";
    #             "ipv6.nat" = "true";
    #             "ipv6.firewall" = "false";
    #           };
    #           # "ipv4.address" = "10.20.0.1/24";
    #           # "ipv4.nat" = "true";
    #           #
    #           # #  "dns.mode" = "none";
    #           # "raw.dnsmasq" = "server=10.10.10.12";
    #           #
    #           # # Keep DHCP (containers still get IPs)
    #           # "ipv4.dhcp" = "true";
    #         };
    #         name = "incusbr0";
    #         type = "bridge";
    #       }
    #     ];
    #
    #     profiles = [
    #       {
    #         devices = {
    #           eth0 = {
    #             name = "eth0";
    #             network = "incusbr0";
    #             type = "nic";
    #           };
    #           root = {
    #             path = "/";
    #             pool = "default";
    #             size = "35GiB";
    #             type = "disk";
    #           };
    #         };
    #         name = "default";
    #         description = "Default Incus Profile";
    #       }
    #
    #       # Adguard Profile
    #       {
    #         devices = {
    #           eth0 = {
    #             name = "eth0";
    #             network = "incusbr0";
    #             type = "nic";
    #           };
    #           root = {
    #             path = "/";
    #             pool = "default";
    #             # size = "35GiB";
    #             type = "disk";
    #           };
    #         };
    #         config = {
    #           # Set AdGuard as DNS server for containers using this profile
    #           "user.network-config" = ''
    #             version: 2
    #             ethernets:
    #               eth0:
    #                 dhcp4: true
    #                 nameservers:
    #                   addresses: [10.10.10.12]
    #           '';
    #         };
    #         name = "thein3rovert";
    #       }
    #     ];
    #
    #     storage_pools = [
    #       {
    #         config = {
    #           source = "/var/lib/incus/storage-pools/default";
    #         };
    #         driver = "dir";
    #         name = "default";
    #       }
    #     ];
    #   };
    #

    # Incus Networking Base
    networking = {
      nftables = {
        enable = true;
      };
      firewall.interfaces.incusbr0.allowedTCPPorts = [
        53
        67
      ];
      firewall.interfaces.incusbr0.allowedUDPPorts = [
        53
        67
      ];
    };

    # Add Inucus to extra group
    # TODO: Use homelab user as base users or add incus-admin to homelab base
    users.users.thein3rovert.extraGroups = [ "incus-admin" ];

  };
}
