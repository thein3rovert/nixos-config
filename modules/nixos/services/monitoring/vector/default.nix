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
            .host, err = get_hostname()
            if err != null {
              if .host == null {
                .host = "unknown"
              }
            }
            .unit = del(._SYSTEMD_UNIT)
            if .unit == null { .unit = "unknown" }

            # Drop pure noise (HML-041): login session scopes carry nothing
            unit_str = string(.unit) ?? ""
            if match(unit_str, r'^session-[0-9]+[.]scope$') { abort }

            # Drop info/debug spam from the two chattiest units, keep warnings+
            # (journal numeric priority: 4 = warning, 6 = info, 7 = debug)
            pri = .PRIORITY
            if pri == null { pri = "7" }
            if (.unit == "podman-kestra.service" || .unit == "podman.service") && (to_int(pri) ?? 7) > 4 { abort }
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
