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

  createOption = mkOption;
  mapAttribute = lib.mapAttrs;
  if-nginx-enable = mkIf config.nixosSetup.services.nginx.enable;
  cfg = config.nixosSetup.services.nginx;

  # Types used
  attributeSetOf = types.attrsOf;
  subModule = types.submodule;
  string = types.str;
  list = types.listOf;
  boolean = types.bool;
  port = types.port;
  integer = types.int;

in
{
  # Define options schema - mkEnableOption creates a boolean option with default false
  # wrapping in inside enable it better
  options.nixosSetup.services.garage = {
    enable = lib.mkEnableOption "S3 services";
  };
  config = lib.mkIf config.nixosSetup.services.garage.enable {
    garageLogLevel = createOption {
      type = string;
      default = "info";
    };

    garageSettings = mkOption {
      type = attributeSetOf (subModule {
        metadata_dir = createOption {
          type = string;
          description = "The directory for the Meta_data needed";
        };

        data_dir = createOption {
          type = string;
          description = "The directory for the data needed";
        };

        replication_factor = createOption {
          type = integer;
          description = "The directory for the data needed";
        };

        web_bind_addr = createOption {
          type = string;
          description = "The directory for the data needed";
        };

        rpc_bind_addr = createOption {
          type = string;
          description = "The directory for the data needed";
        };

        rpc_public_addr = createOption {
          type = string;
          description = "The directory for the data needed";
        };

        # TODOl Change types to path for agenix
        rpc_secret = createOption {
          type = string;
          description = "The directory for the data needed";
        };

        admin_token = createOption {
          type = string;
          description = "The directory for the data needed";
        };
        # Add S3 config for settings.
        s3_api = createOption {
          type = list (subModule {
            options = {

              api_bind_addr = createOption {
                type = string;
                description = "The directory for the data needed";
              };

              s3_region = createOption {
                type = string;
                description = "The directory for the data needed";
              };
              root_domain = createOption {
                type = string;
                description = "The directory for the data needed";
              };

            };

          });
        };

      });
    };
    services.garage = {
      enable = true;
      package = pkgs.garage;
      extraEnvironment = {
        RUST_BACKTRACE = "yes";
      };

    };
  };
}
