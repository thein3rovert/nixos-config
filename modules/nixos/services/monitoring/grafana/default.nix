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
    ;

  # Custom helper functions
  createEnableOption = mkEnableOption;
  If = mkIf;
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
          security.secret_key = "tesst-pass";
          server = {
            http_addr = "0.0.0.0";
            http_port = config.myDns.networkMap.localNetworkMap.grafana.port;
            domain = config.myDns.networkMap.localNetworkMap.grafana.vHost;
          };
        };

        provision = {
          enable = true;

          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.myDns.networkMap.localNetworkMap.prometheus.port}";
            }
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
            path_prefix = "/var/lib/loki";

            storage = {
              filesystem = {
                chunks_directory = "/var/lib/loki/chunks";
                rules_directory = "/var/lib/loki/rules";
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
        globalConfig.scrape_interval = "60s";
        inherit (config.myDns.networkMap.localNetworkMap.prometheus) port;

        # Blackbox exporter - HTTP probing of internal vHosts from roan.
        # Internal domains resolve to nixos Tailscale IP via MagicDNS,
        # so probes exercise the full traefik routing path end-to-end.
        exporters.blackbox = {
          enable = true;
          port = config.homelab.servicePorts.blackbox;
          configFile = pkgs.writeText "blackbox.yml" ''
            modules:
              http_2xx:
                prober: http
                timeout: 10s
                http:
                  preferred_ip_protocol: ip4
          '';
        };

        scrapeConfigs = [
          # {
          #   job_name = "smartctl";
          #   static_configs = [
          #     {
          #       targets = [ "jubilife:9633" ];
          #       labels.instance = "nixos";
          #     }
          #   ];
          # }

          # Node Exporter - Scrapes metrics from all hosts via HTTP on port 3021
          # Uses Tailscale network for connectivity (hostnames resolve via MagicDNS)
          #
          # NOTE: Can use either hostnames OR Tailscale IPs:
          #   targets = [ "becca:3021" ];           # Hostname (requires MagicDNS)
          #   targets = [ "100.123.31.22:3021" ];   # Tailscale IP (more reliable, no DNS lookup)
          #
          # Prometheus polls these HTTP endpoints every 60 seconds (see globalConfig.scrape_interval)
          # No SSH/agents needed - pure HTTP GET requests to /metrics endpoint
          {
            job_name = "node";
            static_configs = [
              # NixOS hosts
              # {
              #   targets = [ "marcus:3021" ];
              #   labels.instance = "marcus";
              # }
              # {
              #   targets = [ "finn:3021" ];
              #   labels.instance = "finn";
              # }
              # {
              #   targets = [ "k3s-server:3021" ];
              #   labels.instance = "k3s-server";
              # }
              {
                targets = [ "bellamy:3021" ];
                labels.instance = "bellamy";
              }
              {
                targets = [ "nixos:3021" ];
                labels.instance = "nixos";
              }
              # Ubuntu hosts
              {
                targets = [ "becca:3021" ];
                labels.instance = "becca";
              }
              {
                targets = [ "github-runner:3021" ];
                labels.instance = "github-runner";
              }
              {
                targets = [ "trikru:3021" ];
                labels.instance = "trikru";
              }
              {
                targets = [ "lincoln:3021" ];
                labels.instance = "lincoln";
              }
              {
                targets = [ "raven:3021" ];
                labels.instance = "raven";
              }
            ];
          }

          # Blackbox - Probes internal vHosts through nixos traefik.
          # Targets derive from networkMap so renames track automatically.
          # Complements uptime-kuma on bellamy (public) with internal-path coverage.
          # NOTE: n8n excluded (service off); loki probed at /ready (no homepage).
          {
            job_name = "blackbox-http";
            metrics_path = "/probe";
            params.module = [ "http_2xx" ];
            static_configs = [
              {
                targets =
                  map (name: "http://${config.myDns.networkMap.localNetworkMap.${name}.vHost}/") [
                    "grafana"
                    "garage-webui"
                    "kaneo"
                    "dockhand"
                    "zerobyte"
                    "fossflow"
                    "termix"
                    "copyparty"
                    "filebrowser"
                    "syncthing"
                    "vault"
                    "linkding"
                    "kestra"
                    "dbpro-studio"
                  ]
                  ++ [ "http://${config.myDns.networkMap.localNetworkMap.loki.vHost}/ready" ];
              }
            ];
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                target_label = "__param_target";
              }
              {
                source_labels = [ "__param_target" ];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "127.0.0.1:${toString config.homelab.servicePorts.blackbox}";
              }
            ];
          }
        ];
      };

    };
  };
}
