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

    baseDomain = createOption {
      default = "l.thein3rovert.com";
      type = string;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };

    # Port to be used by homelab
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
