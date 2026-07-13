{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixosSetup.services.garage-webui;
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;

  imageName = "noooste/garage-ui";
  imageTag = "latest";

in
{
  options.nixosSetup.services.garage-webui = {
    enable = mkEnableOption "garage-webui (Noooste alternative)";

    waitForServices = mkOption {
      type = types.listOf types.str;
      default = [ "garage.service" ];
      description = "List of services that garage-webui should wait for before starting.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open the default port in the firewall";
    };

    port = mkOption {
      type = types.port;
      default = 3909;
      description = "The port for garage-webui to listen on the host";
    };

    garageEndpoint = mkOption {
      type = types.str;
      default = "127.0.0.1:3900";
      example = "garage:3900";
      description = "Garage S3 API endpoint (host:port)";
    };

    garageAdminEndpoint = mkOption {
      type = types.str;
      default = "http://127.0.0.1:3903";
      example = "http://garage:3903";
      description = "Garage admin API endpoint URL";
    };

    serverHost = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host address for the web UI to bind to";
    };

    serverEnvironment = mkOption {
      type = types.enum [ "development" "production" ];
      default = "production";
      description = "Server environment mode";
    };

    jwtPrivateKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Ed25519 private key for JWT authentication.
        
        WARNING: This will be stored in the Nix store and is world-readable.
        For production, use `environmentFile` instead.
        
        Generate with: openssl genpkey -algorithm ED25519
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/garage-webui.env";
      description = ''
        Path to a file containing environment variables for garage-webui.
        
        Available variables:
          GARAGE_UI_GARAGE_ENDPOINT=127.0.0.1:3900
          GARAGE_UI_GARAGE_ADMIN_ENDPOINT=http://127.0.0.1:3903
          GARAGE_UI_SERVER_HOST=0.0.0.0
          GARAGE_UI_SERVER_PORT=8080
          GARAGE_UI_SERVER_ENVIRONMENT=production
          GARAGE_UI_AUTH_JWT_PRIVATE_KEY=<ed25519-private-key>
      '';
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/etc/garage-ui/config.yaml";
      description = "Path to config.yaml file to mount into the container";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.garage-webui = {
      image = "${imageName}:${imageTag}";
      
      # Use host network so container can reach garage on 127.0.0.1
      extraOptions = [ "--network=host" ];
      
      volumes = lib.optionals (cfg.configFile != null) [
        "${cfg.configFile}:/app/config.yaml:ro"
      ];

      environment = {
        GARAGE_UI_GARAGE_ENDPOINT = cfg.garageEndpoint;
        GARAGE_UI_GARAGE_ADMIN_ENDPOINT = cfg.garageAdminEndpoint;
        GARAGE_UI_SERVER_HOST = cfg.serverHost;
        GARAGE_UI_SERVER_PORT = toString cfg.port;
        GARAGE_UI_SERVER_ENVIRONMENT = cfg.serverEnvironment;
      } // lib.optionalAttrs (cfg.jwtPrivateKey != null) {
        GARAGE_UI_AUTH_JWT_PRIVATE_KEY = cfg.jwtPrivateKey;
      };

      environmentFiles = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
    };

    systemd.services."${config.virtualisation.oci-containers.backend}-garage-webui" = {
      wants = cfg.waitForServices;
      after = cfg.waitForServices;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
