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
        };
      };

      # Dynamic Config
      dynamicConfigOptions = {
        http = {
          services.linkding.loadBalancer.servers = [ { url = "http://10.20.0.1:9090/"; } ];
          services.adguard.loadBalancer.servers = [ { url = "http://10.10.10.12:3000/"; } ];
          services.n8n.loadBalancer.servers = [ { url = "http://10.10.10.12:5678/"; } ];
          routers = {
            api = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.traefik.vHost}`)";
              service = "api@internal";
              entryPoints = [ "web" ];
            };
            adguard = {
              rule = "Host(`${config.myDns.networkMap.localNetworkMap.adguard.vHost}`)";
              service = "adguard";
              entryPoints = [ "web" ];
            };
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
          };
        };
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
      ];
    };
  };
}
