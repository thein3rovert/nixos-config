{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    types
    mkOption
    ;

  # Custom helper functions
  createOption = mkOption;
  createEnableOption = mkEnableOption;
  If = mkIf;
  mapAttribute = lib.mapAttrs;

  # Types used
  attributeSetOf = types.attrsOf;
  subModule = types.submodule;
  string = types.str;
  list = types.listOf;
  boolean = types.bool;
  port = types.port;
  integer = types.int;

  cfg = config.nixosSetup.services.garage;
in
{
  # Define options schema
  options.nixosSetup.services.garage = {
    enable = createEnableOption "S3 services via Garage";
    logLevel = createOption {
      type = string;
      default = "info";
      description = "Log level for Garage service";
    };

    metadataDir = createOption {
      type = string;
      default = "/var/lib/garage/meta";
      description = "Directory for Garage metadata storage";
    };

    dataDir = createOption {
      type = string;
      default = "/var/lib/garage/data";
      description = "Directory for Garage data storage";
    };

    replicationFactor = createOption {
      type = integer;
      default = 1;
      description = "Replication factor for Garage cluster";
    };

    rpcBindAddr = createOption {
      type = string;
      default = "[::]:3901";
      description = "Address for internal Garage cluster communications";
    };

    rpcPublicAddr = createOption {
      type = string;
      default = "127.0.0.1:3901";
      description = "Public address for RPC communications";
    };

    # rpcSecret = createOption {
    #   type = string;
    #   default = "$RPC_SECRET";
    #   description = "RPC secret for Garage cluster (generate via `openssl rand -hex 32`)";
    #   example = "ce7d8b8dd7dd981b6ae42f841f59e9687c97cb5a29b1d5a13bbc9ec028a99424";
    # };
    #
    # adminToken = createOption {
    #   type = string;
    #   default = "$ADMIN_TOKEN";
    #   description = "Admin token for Garage web interface";
    # };
    #
    apiBindAddr = createOption {
      type = string;
      default = "0.0.0.0:3903";
      description = "Address for REST/S3 API and web dashboard";
    };

    s3Api = {
      apiBindAddr = createOption {
        type = string;
        default = "0.0.0.0:3900";
        description = "S3 API bind address";
      };

      s3Region = createOption {
        type = string;
        default = "garage";
        description = "S3 region name";
      };

      rootDomain = createOption {
        type = string;
        default = ".s3.garage.localhost";
        description = "Root domain for S3 API";
      };
    };

    s3Web = {
      bindAddr = createOption {
        type = string;
        default = "[::]:3902";
        description = "S3 web interface bind address";
      };

      rootDomain = createOption {
        type = string;
        default = ".web.garage.localhost";
        description = "Root domain for S3 web interface";
      };

      index = createOption {
        type = string;
        default = "index.html";
        description = "Default index file for S3 web interface";
      };
    };

    user = createOption {
      type = string;
      default = "garage";
      description = "User to run Garage service as";
    };

    group = createOption {
      type = string;
      default = "garage";
      description = "Group to run Garage service as";
    };

    webui = {
      enable = createEnableOption "Garage Web UI";

      port = createOption {
        type = port;
        default = 3909;
        description = "Port for the Garage Web UI server";
      };

      configPath = createOption {
        type = string;
        default = "/etc/garage.toml";
        description = "Path to the Garage configuration file";
      };

      basePath = createOption {
        type = string;
        default = "";
        description = "Base path or prefix for Web UI (e.g., /admin)";
      };

      authUserPass = createOption {
        type = types.nullOr string;
        default = null;
        description = "Optional authentication in format 'username:bcrypt_hash'";
        example = "admin:$2y$10$...";
      };

      apiBaseUrl = createOption {
        type = string;
        default = "http://127.0.0.1:3903";
        description = "Garage admin API endpoint URL";
      };

      s3EndpointUrl = createOption {
        type = string;
        default = "http://127.0.0.1:3900";
        description = "S3 API endpoint URL";
      };
    };
  };

  # Implementation using the options
  config = If cfg.enable {
    services.garage = {
      enable = true;
      package = pkgs.garage_2;
      environmentFile = config.age.secrets.garage-env.path;

      extraEnvironment = {
        RUST_BACKTRACE = "yes";
      };

      logLevel = cfg.logLevel;

      settings = {
        metadata_dir = cfg.metadataDir;
        data_dir = cfg.dataDir;
        replication_factor = cfg.replicationFactor;

        rpc_bind_addr = cfg.rpcBindAddr;
        rpc_public_addr = cfg.rpcPublicAddr;
        # rpc_secret = cfg.rpcSecret;

        # web_bind_addr = cfg.webBindAddr;
        # admin_token = cfg.adminToken;

        s3_api = {
          api_bind_addr = cfg.s3Api.apiBindAddr;
          s3_region = cfg.s3Api.s3Region;
          root_domain = cfg.s3Api.rootDomain;
        };

        # Since i am not using the web
        # s3_web = {
        #   bind_addr = cfg.s3Web.bindAddr;
        #   root_domain = cfg.s3Web.rootDomain;
        #   index = cfg.s3Web.index;
        # };

        admin = {
          api_bind_addr = cfg.apiBindAddr;
        };
      };
    };

    users.groups.${cfg.group} = { };

    systemd.services.garage.serviceConfig = {
      DynamicUser = false;
      User = cfg.user;
      Group = cfg.group;
    };

    # Garage Web UI service
    # systemd.services.garage-webui = If cfg.webui.enable {
    #   description = "Garage Web UI";
    #   after = [
    #     "network.target"
    #     "garage.service"
    #   ];
    #   wantedBy = [ "multi-user.target" ];
    #
    #   serviceConfig = {
    #     Type = "simple";
    #     Restart = "on-failure";
    #     RestartSec = "5s";
    #     EnvironmentFile = config.age.secrets.garage-env.path;
    #   };
    #
    #   environment = {
    #     PORT = toString cfg.webui.port;
    #     CONFIG_PATH = cfg.webui.configPath;
    #     API_BASE_URL = cfg.webui.apiBaseUrl;
    #     S3_REGION = cfg.s3Api.s3Region;
    #     S3_ENDPOINT_URL = cfg.webui.s3EndpointUrl;
    #   }
    #   // (if cfg.webui.basePath != "" then { BASE_PATH = cfg.webui.basePath; } else { })
    #   // (if cfg.webui.authUserPass != null then { AUTH_USER_PASS = cfg.webui.authUserPass; } else { });
    #
    #   script = ''
    #     # Debug: show what we're setting
    #     echo "Setting API_ADMIN_KEY from GARAGE_ADMIN_TOKEN"
    #     echo "GARAGE_ADMIN_TOKEN length: ''${#GARAGE_ADMIN_TOKEN}"
    #
    #     # Use GARAGE_ADMIN_TOKEN from environmentFile as API_ADMIN_KEY
    #     export API_ADMIN_KEY="''${GARAGE_ADMIN_TOKEN}"
    #     echo "API_ADMIN_KEY set, length: ''${#API_ADMIN_KEY}"
    #
    #     exec ${pkgs.garage-webui}/bin/garage-webui
    #   '';
    # };

    # The garage service already creates /etc/garage.toml, so webui can optionally read it
  };
}
