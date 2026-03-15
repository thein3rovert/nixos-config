{
  config,
  lib,
  ...
}:
let

  /*
     WARNING: When ever the config is broken, it requires we restart the preseed manually
      using the command systemctl start incus-preseed.services. Issue might be fixed in later version
  */
  cfg = config.nixosSetup.programs.incus-v;
in
{
  options.nixosSetup.programs.incus-v.enable = lib.mkEnableOption ''
    incusd, a daemon that manages containers and virtual machines.
  '';
  config = lib.mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;
      ui.enable = true;

      preseed = {

        # ================================
        #        INCUS NETWOTK SETTINGS
        # ================================
        config = {

          "core.https_address" = ":8443";
        };

        networks = [
          {

            # ---- Network 1: Default ----

            name = "internalbr0"; # internalbr0
            description = "Default: Internal/NATted bridge";
            type = "bridge";
            config = {
              "ipv4.address" = "10.10.20.1/24";
              "ipv4.nat" = "true";

              "ipv6.address" = "auto";
              "ipv6.nat" = "true";
            };
          }

          # Access container from any server on the same LAN
          # macvlan over WiFi doesn't work
          # {
          #   name = "lanbr0";
          #   description = "Custom: LAN bridge for direct access";
          #   type = "macvlan";
          #   config = {
          #     "parent" = "wlo1"; # your LAN/WIFI interface
          #   };
          # }

        ];
        # ============================================
        #        INCUS PROFILE SETTINGS
        # ============================================
        profiles = [
          {
            name = "default";
            description = "Default Incus Profile Nixos";
            config = {
              "security.nesting" = "true";
            };

            devices = {
              eth0 = {
                name = "eth0";
                network = "internalbr0";
                type = "nic";
              };

              # New interface for serving LAN bridge
              # macvlan over WiFi doesn't work:
              # eth1 = {
              #   name = "eth1";
              #   network = "lanbr0";
              #   type = "nic";
              # };

              root = {
                type = "disk";
                pool = "default";
                path = "/";
              };
            };
          }

          # ---- Additional Bridge: Optional ----
          # {
          #   name = "bridged";
          #   description = "Instances bridged to LAN";
          #   devices = {
          #     eth0 = {
          #       name = "eth0";
          #       nictype = "bridged";
          #       parent = "externalbr0";
          #       type = "nic";
          #     };
          #     root = {
          #       path = "/";
          #       pool = "default";
          #       type = "disk";
          #     };
          #   };
          # }
        ];

        # ============================================
        #        INCUS STORAGE POOL SETTINGS
        # ============================================

        # ---- Storage Pool 1: Default ----
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
      };

    };

    # Incus Networking Base
    networking = {
      nftables = {
        enable = true;
      };
      useDHCP = lib.mkForce true;
      # interfaces.eth1.useDHCP = true;

      tempAddresses = "disabled";
      hostId = "247140c6";
      hostName = "marcus"; # change this
      firewall.trustedInterfaces = [
        "internalbr0"
      ];

      # INFO: Only needed when bridge is present
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

    };

    # Add Inucus to extra group
    # TODO: Use homelab user as base users or add incus-admin to homelab base
    users.users.thein3rovert.extraGroups = [ "incus-admin" ];

  };
}
