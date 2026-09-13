{
  config,
  lib,
  ...
}:
{
  options.nixosSetup.services.vector = {
    enable = lib.mkEnableOption "Vector log shipper to Loki";

    lokiEndpoint = lib.mkOption {
      description = "Loki base URL Vector reports to (push path appended by Vector)";
      default = "http://${config.homelab.ipRegistry.loki.url}";
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.nixosSetup.services.vector.enable {
    services.vector = {
      enable = true;
      # nixpkgs runs Vector as DynamicUser - journal access via this flag,
      # not a static users.users.vector entry (that breaks evaluation).
      journaldAccess = true;

      settings = {
        data_dir = "/var/lib/vector";

        sources.journald = {
          type = "journald";
        };

        transforms.normalize = {
          type = "remap";
          inputs = [ "journald" ];
          source = ''
            if .host == null { .host = get_hostname() }
            .unit = del(._SYSTEMD_UNIT)
            if .unit == null { .unit = "unknown" }
          '';
        };

        sinks.loki = {
          type = "loki";
          inputs = [ "normalize" ];
          endpoint = config.nixosSetup.services.vector.lokiEndpoint;
          labels = {
            host = "{{ host }}";
            unit = "{{ unit }}";
          };
          encoding.codec = "json";
        };
      };
    };
  };
}
