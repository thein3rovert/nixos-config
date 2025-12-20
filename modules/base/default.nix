{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  #Types
  string = types.str;

  # custom
  cfg = config.homelab;

  # Functions
  If = mkIf;
  createEnableOption = mkEnableOption;
  createOption = mkOption;
  attributeSetOf = types.attrsOf;
in
{
  imports = [
    ./ports
  ];

  options.homelab = {
    enable = createEnableOption "My homelab services and configuration variables";
    baseUser = createOption {
      default = "thein3rovert";
      type = string;
      description = ''
        User to run the base homelab service as
      '';
    };

    user = createOption {
      default = "share";
      type = string;
      description = ''
        User to run the hoelab service as
      '';
    };

    default = "share";
    group = createOption {
      type = string;
      description = ''
        Group to run the hoelab service as
      '';
    };

    timeZone = createOption {
      default = "Europe/London";
      type = string;
      description = ''
        TimeZone to use for homelab services
      '';
    };

    # ============================================
    #
    #           Network Configuration
    # TODO: Add the right descriptions to each
    # ============================================
    baseDomain = createOption {
      default = "l.thein3rovert.com";
      type = string;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };

    # ============================================
    # DNS Configuration
    # ============================================
    dns = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    con-dns = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    vm-dns = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    # ============================================
    # Gateway Configuration
    # ============================================

    gateway = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    con-gateway = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    vm-gateway = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };

    # ============================================
    # Ip address Configuration
    # ============================================
    ipAddresses = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    con-IpAddress = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    vm-IpAddress = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };

    # ============================================
    # Network Interface Configuration
    # ============================================
    networkInterface = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    con-NetworkInterface = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    vm-NetworkInterface = createOption {
      type = lib.types.attrsOf lib.types.string;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };

    # ============================================
    # Ports Configuration
    # ============================================
    containerPorts = createOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    servicePorts = createOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Ports used by Nixos Services";
    };
    customPorts = createOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Ports used by custom Services and Applications";
    };

    # ============================================
    # Storage Configuration
    # ============================================

    servicesStorage = createOption {
      type = attributeSetOf (
        types.submodule {
          options = {
            path = createOption {
              type = string;
              description = "Path to the Volume";
            };

            owner = createOption {
              type = string;
              default = cfg.baseUser;
              description = "Owner of the volume";
            };

            group = createOption {
              type = string;
              default = cfg.group;
              description = "Group of the volume";
            };

            permissions = createOption {
              type = string;
              default = "755";
              description = "Permissions for the volume";
            };

          };
        }
      );
    };
  };

  # If BaseDoman is enabled
  config = If cfg.enable {
    # Create new user group and users
    users = {
      groups.${cfg.group} = {
        gid = 993;
      };

      users.${cfg.user} = {
        uid = 994;
        isSystemUser = true;
        group = cfg.group;
      };
    };

  };

}
