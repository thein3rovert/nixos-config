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
          # INFO: Holding off on configuring bridge as Ethernet interface
          # is currently down( Live Ethernate Cable needed)

          # {
          #   name = "bridged";
          #   description = "Instances bridged to LAN";
          #
          #   devices = {
          #     eth0 = {
          #       name = "eth0";
          #       nictype = "bridged";
          #       parent = "externalbr0";
          #       type = "nic";
          #     };
          #
          #     root = {
          #       path = "/";
          #       pool = "default";
          #       type = "disk";
          #     };
          #   };
          # }

        ];
      };

    };

    # Incus Networking Base
    networking = {
      nftables = {
        enable = true;
      };
      useDHCP = false;
      tempAddresses = "disabled";
      hostId = "007f0200"; # change this to something unique on your network
      hostName = "nixos"; # change this
      firewall.trustedInterfaces = [ "incusbr0" ];

      # bridges = {
      #   externalbr0 = {
      #     interfaces = [ "wlp1s0" ]; # change this to your network adapter
      #   };
      # };
      # interfaces = {
      #   externalbr0 = {
      #     useDHCP = true;
      #     macAddress = "b0:ac:82:c8:32:ff";
      #   };
      # };

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
