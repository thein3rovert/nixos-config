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

  cfg = config.nixosSetup.services.grafana;
in
{
  # Define options schema
  options.nixosSetup.services.grafana = {
    enable = createEnableOption "Monitoring Grafana";
  };

  config = If cfg.enable {
    services = {
      grafana = {
        enable = true;

        settings = {
          server = {
            http_addr = "0.0.0.0";
            http_port = config.myDns.networkMap.localNetworkMap.grafana.port;
            domain = config.myDns.networkMap.localNetworkMap.grafana.vHost;
          };
        };

        provision = {
          enable = true;

          datasources.settings.datasources = [
            # {
            #   name = "Prometheus";
            #   type = "prometheus";
            #   access = "proxy";
            #   url = "https://${config.mySnippets.tailnet.networkMap.prometheus.vHost}";
            # }
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.myDns.networkMap.localNetworkMap.loki.port}";
            }
          ];
        };
      };

      # ==================================
      #        LOKI configuration
      # ==================================
      loki = {
        enable = true;

        configuration = {
          auth_enabled = false;

          server = {
            http_listen_port = config.myDns.networkMap.localNetworkMap.loki.port;
            grpc_listen_port = 0;
          };

          common = {
            instance_addr = "0.0.0.0";
            path_prefix = "/tmp/loki";

            storage = {
              filesystem = {
                chunks_directory = "/tmp/loki/chunks";
                rules_directory = "/tmp/loki/rules";
              };
            };

            replication_factor = 1;

            ring = {
              kvstore = {
                store = "inmemory";
              };
            };
          };

          frontend = {
            max_outstanding_per_tenant = 2048;
          };

          pattern_ingester = {
            enabled = true;
          };

          limits_config = {
            max_global_streams_per_user = 0;
            ingestion_rate_mb = 50000;
            ingestion_burst_size_mb = 50000;
            volume_enabled = true;
          };

          query_range = {
            results_cache = {
              cache = {
                embedded_cache = {
                  enabled = true;
                  max_size_mb = 100;
                };
              };
            };
          };

          schema_config = {
            configs = [
              {
                from = "2020-10-24";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };

          analytics = {
            reporting_enabled = false;
          };
        };
      };

      prometheus = {
        enable = true;
        globalConfig.scrape_interval = "10s";
        inherit (config.myDns.networkMap.localNetworkMap.prometheus) port;

        scrapeConfigs = [
          # {
          #   job_name = "smartctl";
          #   static_configs = [
          #     {
          #       targets = [ "jubilife:9633" ];
          #       labels.instance = "jubilife";
          #     }
          #   ];
          # }
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "bellamy:3021" ];
                labels.instance = "bellamy";
              }
              {
                targets = [ "marcus:3021" ];
                labels.instance = "marcus";
              }
            ];
          }
        ];
      };

    };
  };
}
