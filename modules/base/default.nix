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
  options.homelab = {
    enable = createEnableOption "My homelab services and configuration variables";

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
      default = "";
      type = string;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
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
