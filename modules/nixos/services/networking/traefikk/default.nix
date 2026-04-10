{
  config,
  lib,
  ...
}:
{
  options.nixosSetup.services.traefikk = {
    enable = lib.mkEnableOption "Treafik Reverse Proxy";
  };

  config = lib.mkIf config.nixosSetup.services.traefikk.enable {
    services.traefik = {
      enable = true;

      staticConfigOptions = {
        log = {
          level = "DEBUG";
        };

        api = {
          dashboard = true;
          insecure = true;
        };

        providers.docker = {
          endpoint = "unix:///run/podman/podman.sock";
          exposedByDefault = false;
          network = "traefik_proxy";
        };
        entryPoints = {
          web = {
            address = ":80";
          };
          websecure = {
            address = ":443";
          };
          incus-passthrough = {
            address = ":8444"; # Use a different port
          };
        };
        serversTransport = {
          insecureSkipVerify = true;
        };
      };

      # Dynamic Config
      dynamicConfigOptions = {

        middlewares = {
          # Fix: rewrite Host header to what ActivityWatch expects
          activitywatch-rewrite-hostheader = {
            headers.customRequestHeaders = {
              Host = "localhost:5600";
            };
          };
        };
        http = {
          services.linkding.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.linkding.url}/"; }
          ];
          services.n8n.loadBalancer.servers = [ { url = "http://${config.homelab.ipRegistry.n8n.url}/"; } ];
          services.kestra.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.kestra.url}/"; }
          ];
          services.termix.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.termix.url}/"; }
          ];
          services.zerobyte.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.zerobyte.url}/"; }
          ];

          # Container LXC
          services.ad-guard.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.ad-guard.url}/"; }
          ];
          services.fossflow.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.fossflow.url}/"; }
          ];
          services.dockhand.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.dockhand.url}/"; }
          ];
          services.garage-webui.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.garage-webui.url}/"; }
          ];
          services.copyparty.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.copyparty.url}/"; }
          ];
          services.filebrowser.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.filebrowser.url}/"; }
          ];

          # Monitoring
          services.grafana.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.grafana.url}/"; }
          ];
          services.loki.loadBalancer.servers = [ { url = "http://${config.homelab.ipRegistry.loki.url}/"; } ];
          services.vault.loadBalancer.servers = [
            { url = "http://${config.homelab.ipRegistry.vault.url}/"; }
          ];

          routers = {
            api = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.traefik.vHost}`)";
              service = "api@internal";
              entryPoints = [ "web" ];
            };
            # adguard = {
            #   rule = "Host(`${config.myDns.networkMap.localNetworkMap.adguard.vHost}`)";
            #   service = "adguard";
            #   entryPoints = [ "web" ];
            # };
            linkding = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.linkding.vHost}`)";
              service = "linkding";
              entryPoints = [ "web" ];
            };
            n8n = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.n8n.vHost}`)";
              service = "n8n";
              entryPoints = [ "web" ];
            };
            kestra = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.kestra.vHost}`)";
              service = "kestra";
              entryPoints = [ "web" ];
            };
            termix = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.termix.vHost}`)";
              service = "termix";
              entryPoints = [ "web" ];
            };
            zerobyte = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.zerobyte.vHost}`)";
              service = "zerobyte";
              entryPoints = [ "web" ];
            };

            # Architecture Diagram
            fossflow = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.fossflow.vHost}`)";
              service = "fossflow";
              entryPoints = [ "web" ];
            };

            ## Container LXC
            ad-guard = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.ad-guard.vHost}`)";
              service = "ad-guard";
              entryPoints = [ "web" ];
            };
            garage-webui = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.garage-webui.vHost}`)";
              service = "garage-webui";
              entryPoints = [ "web" ];
            };
            dockhand = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.dockhand.vHost}`)";
              service = "dockhand";
              entryPoints = [ "web" ];
            };
            grafana = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.grafana.vHost}`)";
              service = "grafana";
              entryPoints = [ "web" ];
            };
            loki = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.loki.vHost}`)";
              service = "loki";
              entryPoints = [ "web" ];
            };
            vault = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.vault.vHost}`)";
              service = "vault";
              entryPoints = [ "web" ];
            };
            copyparty = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.copyparty.vHost}`)";
              service = "copyparty";
              entryPoints = [ "web" ];
            };
            filebrowser = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.filebrowser.vHost}`)";
              service = "filebrowser";
              entryPoints = [ "web" ];
            };

            # incus = {
            #   rule = "HostSNI(`${config.myDns.networkMap.localNetworkMap.incus.vHost}`)";
            #   service = "incus";
            #   entryPoints = [ "incus-passthrough" ];
            #   tls = {
            #     passthrough = true;
            #   };
            # };

          };

        };

        tcp = {
          routers.incus = {
            rule = "HostSNI(`${config.myDns.networkMap.localNetworkMap.incus.vHost}`)";
            service = "incus";
            entryPoints = [ "websecure" ];
            tls.passthrough = true;
          };
          routers.incus-v2 = {
            rule = "HostSNI(`${config.myDns.networkMap.localNetworkMap.incus-v2.vHost}`)";
            service = "incus-v2";
            entryPoints = [ "websecure" ];
            tls.passthrough = true;
          };

          services.incus-v2.loadBalancer.servers = [
            { address = "${config.homelab.ipRegistry.incus-v2.url}"; }
          ];

          services.incus.loadBalancer.servers = [
            { address = "${config.homelab.ipRegistry.incus.url}"; }
          ];
        };

        # serversTransports = {
        #   incusTransport = {
        #     insecureSkipVerify = true;
        #   };
        # };
      };

    };

    system.activationScripts = {
      traefikDirectories = {
        text = ''
          mkdir -p /var/lib/traefik
          chmod 755 /var/lib/traefik
        '';
        deps = [ ];
      };
    };

    # Create traefik user/group
    users.users.traefik = {
      group = "traefik";
      isSystemUser = true;
      extraGroups = [
        "podman"
        "docker"
        "tailscale"
      ];
    };
    users.groups.traefik = { };

    # Firewall configuration
    networking.firewall = {
      allowedTCPPorts = [
        80
        443
        # incus firewall
        8444
      ];
    };
  };
}
