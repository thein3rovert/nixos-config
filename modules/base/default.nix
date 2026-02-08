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
  listOf = types.listOf;

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
    ./storage
    ./containers
    ./networks
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
    baseGroup = createOption {
      type = string;
      default = "users";
      description = ''
        Group to run the hoelab group as
      '';
    };

    user = createOption {
      default = "share";
      type = string;
      description = ''
        User to run the hoelab service as
      '';
    };

    group = createOption {
      type = string;
      default = "share";
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
    # Ports Configuration
    # ============================================
    containerPorts = createOption {
      type = lib.types.attrsOf (lib.types.either lib.types.int (lib.types.listOf lib.types.int));
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    # servicePorts = createOption {
    #   type = lib.types.attrsOf lib.types.int;
    #   default = { };
    #   description = "Ports used by Nixos Services";
    # };
    servicePorts = createOption {
      type = lib.types.attrsOf (lib.types.either lib.types.int (lib.types.listOf lib.types.int));
      default = { };
      description = "Ports used by Nixos Podman services";
    };
    customPorts = createOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Ports used by custom Services and Applications";
    };

    # ============================================
    # Container Configuration
    # ============================================
    containers = {
      runtime = createOption {
        type = types.enum [
          "podman"
          "docker"
        ];
        default = "podman";
        description = "Container runtime to use";
      };

      network = createOption {
        type = string;
        default = "homelab";
        description = "Default container network name";
      };

      storageDriver = createOption {
        type = string;
        default = "overlay2";
        description = "Container storage driver";
      };
    };

    # ============================================
    # Host Information
    # ============================================
    hostInfo = {
      hostname = createOption {
        type = string;
        default = "homelab";
        description = "Hostname of the server";
      };

      architecture = createOption {
        type = types.enum [
          "x86_64"
          "aarch64"
        ];
        default = "x86_64";
        description = "System architecture";
      };

      location = createOption {
        type = string;
        default = "home";
        description = "Physical location of the server";
      };
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
              # NOTE: Find a better base permission
              default = "755";
              description = "Permissions for the volume";
            };
          };
        }
      );
    };
    containerStorage = createOption {
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
              # NOTE: Find a better base permission
              default = "755";
              description = "Permissions for the volume";
            };
          };
        }
      );
    };
  };

  config = If cfg.enable {
    # ============================================
    # User Management
    # ============================================
    # users = {
    #   groups.${cfg.group} = {
    #     gid = 993;
    #   };
    #
    #   users.${cfg.user} = {
    #     uid = 994;
    #     isSystemUser = true;
    #     group = cfg.group;
    #   };
    # };
    # ============================================
  };

}
