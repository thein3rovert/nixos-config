{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Define options schema - mkEnableOption creates a boolean option with default false
  # wrapping in inside enable it better
  options.nixosSetup.services.garage = {
    enable = lib.mkEnableOption "S3 services";
  };
  config = lib.mkIf config.nixosSetup.services.garage.enable {
    services.garage = {
      enable = true;
      package = pkgs.garage;
      extraEnvironment = {
        RUST_BACKTRACE = "yes";
      };

      # TODO: Add age path
      # environmentFile = [ ];

      logLevel = "info";
      settings = {
        metadata_dir = "/var/lib/garage/meta";
        data_dir = "/var/lib/garage/data";

        replication_factor = 1;
        # Required network settings:
        # rpc_bind_addr = "0.0.0.0:3901"; # internal Garage cluster comms
        web_bind_addr = "0.0.0.0:3902"; # REST/S3 API and web dashboard

        rpc_bind_addr = "[::]:3901"; # internal Garage cluster comms
        rpc_public_addr = "127.0.0.1:3901";
        rpc_secret = "ce7d8b8dd7dd981b6ae42f841f59e9687c97cb5a29b1d5a13bbc9ec028a99424"; # generate via `openssl rand -hex 32`

        # For demo/testing purposes, set a simple admin token:
        admin_token = "changeme";
        s3_api = {
          # List of addresses ("LISTEN ADDRS", see Garage documentation)
          api_bind_addr = "0.0.0.0:3900";
          s3_region = "garage";
          root_domain = ".s3.garage.localhost";
          # You may add more S3 API options if needed, see Garage docs.
        };

        s3_web = {
          bind_addr = "[::]:3902";
          root_domain = ".web.garage.localhost";
          index = "index.html";
        };
      };

    };
    # users.users.garage = {
    #   isSystemUser = true;
    #   group = "garage";
    #   home = "/var/lib/garage";
    # };

    users.groups.garage = { };
    systemd.services.garage.serviceConfig = {
      DynamicUser = false;
      User = "thein3rovert";
      Group = "users";
    };
  };
}
