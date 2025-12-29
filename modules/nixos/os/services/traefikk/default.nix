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
          # TODO: Encapsulate IP and Port in variable
          # Example:
          # homelab.local.ip, homelab.vm.ip homelab.container.ip

          services.linkding.loadBalancer.servers = [ { url = "http://10.20.0.1:9090/"; } ];
          # services.adguard.loadBalancer.servers = [ { url = "http://10.10.10.12:3000/"; } ];
          services.n8n.loadBalancer.servers = [ { url = "http://10.10.10.12:5678/"; } ];
          services.zerobyte.loadBalancer.servers = [ { url = "http://127.0.0.1:4096/"; } ];

          # Container LXC
          services.ad-guard.loadBalancer.servers = [ { url = "http://10.10.10.10:3000/"; } ];
          services.fossflow.loadBalancer.servers = [ { url = "http://10.10.10.12:8087/"; } ];
          services.garage-webui.loadBalancer.servers = [
            {
              url = "http://100.105.187.63:3909/";
            }
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
              rule = "Host(`s3-web.l.thein3rovert.com`)";
              service = "garage-webui";
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
          services.incus.loadBalancer.servers = [
            { address = "10.10.10.12:8443"; }
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
