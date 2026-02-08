{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  # custom
  cfg = config.homelab;

  # Functions
  If = mkIf;
in
{
  imports = [
    ./storage
    ./containers
    ./networks
  ];

  options.homelab = {
    enable = mkEnableOption "My homelab services and configuration variables";
    baseUser = mkOption {
      default = "thein3rovert";
      type = types.str;
      description = ''
        User to run the base homelab service as
      '';
    };
    baseGroup = mkOption {
      type = types.str;
      default = "users";
      description = ''
        Group to run the hoelab group as
      '';
    };

    user = mkOption {
      default = "share";
      type = types.str;
      description = ''
        User to run the hoelab service as
      '';
    };

    group = mkOption {
      type = types.str;
      default = "share";
      description = ''
        Group to run the hoelab service as
      '';
    };

    timeZone = mkOption {
      default = "Europe/London";
      type = types.str;
      description = ''
        TimeZone to use for homelab services
      '';
    };

    # ============================================
    # Container Configuration
    # ============================================
    containers = {
      runtime = mkOption {
        type = types.enum [
          "podman"
          "docker"
        ];
        default = "podman";
        description = "Container runtime to use";
      };

      network = mkOption {
        type = types.str;
        default = "homelab";
        description = "Default container network name";
      };

      storageDriver = mkOption {
        type = types.str;
        default = "overlay2";
        description = "Container storage driver";
      };
    };

    # ============================================
    # Host Information
    # ============================================
    hostInfo = {
      hostname = mkOption {
        type = types.str;
        default = "homelab";
        description = "Hostname of the server";
      };

      architecture = mkOption {
        type = types.enum [
          "x86_64"
          "aarch64"
        ];
        default = "x86_64";
        description = "System architecture";
      };

      location = mkOption {
        type = types.str;
        default = "home";
        description = "Physical location of the server";
      };
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
