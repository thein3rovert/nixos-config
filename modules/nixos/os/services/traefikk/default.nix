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
          insecure = false;
        };

        providers.docker = {
          endpoint = "unix:///run/podman/podman.sock";
          exposedByDefault = false;
          network = "traefik_proxy";
        };

        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure = {
            address = ":443";
          };
        };

        # Certificate Resolver Option
        certificatesResolvers = {
          myresolver.tailscale = { };
        };
      };

      # Dynamic Config
      dynamicConfigOptions = {
        http = {
          middlewares = {
            auth = {
              basicAuth = {
                users = [
                  "thein3rovert:$apr1$R7282Dcn$A6VkhZibkhspsDhasYRXK1"
                ]; # Use hash for password using nix-shell -p apacheHttpd [htpasswd]
              };
            };
          };

          routers = {
            routertailscale = {
              rule = "Host(`thein3rovert.tailf87228.ts.net`)";
              service = "api@internal";
              entryPoints = [ "websecure" ];
              middlewares = [ "auth" ]; # Activate auth for domain access
              # Configure TLS
              tls = {
                certResolver = "myresolver";
                domains = [
                  {
                    main = "thein3rovert.tailf87228.ts.net";
                    # sans = [ "*.thein3rovert.dev" ]; # Uncomment for wildcard
                  }
                ];
              };
            };
          };
        };
      };
    };

    # Create directory for Traefik
    system.activationScripts = {
      traefikDirectories = {
        text = ''
          mkdir -p /var/lib/traefik
          chmod 755 /var/lib/traefik
        '';
        deps = [ ];
      };
    };

    # # Service configuration
    # systemd.services.traefik = {
    #   serviceConfig = {
    #     EnvironmentFile = [ "${config.age.secrets.godaddy.path}" ];
    #     User = "traefik";
    #     Group = "traefik";
    #   };
    #   after = [ "network-online.target" ];
    #   wants = [ "network-online.target" ];
    # };
    #
    # Create traefik user/group
    users.users.traefik = {
      group = "traefik";
      isSystemUser = true;
      extraGroups = [
        "podman"
        "docker"
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
