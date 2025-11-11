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

            # Enable when using tcp / https
            # http.redirections.entryPoint = {
            #   to = "websecure";
            #   scheme = "https";
            # };
          };
          # Enable when using tcp / https
          # websecure = {
          #   address = ":443";
          # };
        };

        # Enable when using tcp / https
        # Certificate Resolver Option
        # certificatesResolvers = {
        #   tailscale.tailscale = { };
        # };
      };

      # Dynamic Config
      dynamicConfigOptions = {
        http = {
          services.linkding.loadBalancer.servers = [ { url = "http://10.20.0.1:9090/"; } ];
          services.adguard.loadBalancer.servers = [ { url = "http://10.10.10.12:3000/"; } ];
          routers = {
            api = {
              rule = "Host(`traefik.l.thein3rovert.com`)";
              service = "api@internal";
              entryPoints = [ "web" ];
            };
            adguard = {
              rule = "Host(`adguard.l.thein3rovert.com`)";
              service = "adguard";
              entryPoints = [ "web" ];
            };
            linkding = {
              rule = "Host(`linkding.l.thein3rovert.com`)";
              service = "linkding";
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
