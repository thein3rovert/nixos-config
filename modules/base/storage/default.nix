{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.homelab;
in
{
  # ============================================
  # Storage Options
  # ============================================
  options.homelab = {
    servicesStorage = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              description = "Path to the Volume";
            };
            owner = mkOption {
              type = types.str;
              default = cfg.baseUser;
              description = "Owner of the volume";
            };
            group = mkOption {
              type = types.str;
              default = cfg.group;
              description = "Group of the volume";
            };
            permissions = mkOption {
              type = types.str;
              default = "755";
              description = "Permissions for the volume";
            };
          };
        }
      );
      default = { };
      description = "Storage configuration for NixOS services";
    };

    containerStorage = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              description = "Path to the Volume";
            };
            owner = mkOption {
              type = types.str;
              default = cfg.baseUser;
              description = "Owner of the volume";
            };
            group = mkOption {
              type = types.str;
              default = cfg.group;
              description = "Group of the volume";
            };
            permissions = mkOption {
              type = types.str;
              default = "755";
              description = "Permissions for the volume";
            };
          };
        }
      );
      default = { };
      description = "Storage configuration for containers";
    };
  };

  # ============================================
  # Storage Configuration
  # ============================================
  config.homelab = {
    # Container storage configuration
    containerStorage = {
      traefik = {
        path = "/var/lib/containers/traefik";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };

      linkding = {
        path = "/var/lib/containers/linkding";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };

      zerobyte = {
        path = "/var/lib/containers/zerobyte";
        owner = cfg.baseUser;
        group = cfg.baseGroup;
        permissions = "755";
      };

      nginx = {
        path = "/var/lib/containers/nginx";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };
    };

    # Services storage configuration
    servicesStorage = {
      adguard = {
        path = "/var/lib/adguardhome";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };

      ssh = {
        path = "/var/lib/ssh";
        owner = cfg.user;
        group = cfg.group;
        permissions = "700";
      };

      ipam = {
        path = "/var/lib/ipam";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };

      api = {
        path = "/var/lib/api";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };

      media = {
        path = "/srv/media";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };

      backups = {
        path = "/srv/backups";
        owner = cfg.user;
        group = cfg.group;
        permissions = "750";
      };

      config = {
        path = "/srv/config";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };

      logs = {
        path = "/var/log/homelab";
        owner = cfg.user;
        group = cfg.group;
        permissions = "755";
      };
    };
  };
}
