{
  config,
  lib,
  ...
}:
{
  options.nixosSetup.services.traefik = {
    enable = lib.mkEnableOption "Treafik Reverse Proxy";
  };

  config = lib.mkIf config.nixosSetup.services.traefik.enable {
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
          godaddy = {
            acme = {
              email = "danielolaibi@gmail.com";
              storage = "/var/lib/traefik/acme.json";
              caserver = "https://acme-v02.api.letsencrypt.org/directory";
              dnsChallenge = {
                provider = "godaddy";
                resolvers = [
                  "1.1.1.1:53"
                  "8.8.8.8:53"
                ];
                propagation.delayBeforeChecks = 90; # TODO: Change to 90 or 180
                # propagation = {
                #   delaybefore = 90; # Increase from 60 to 90 seconds
                #   timeout = 180; # Add a timeout of 180 seconds
                # };
              };
            };
          };
        };
      };

      # Dynamic Config
      dynamicConfigOptions = {
        http = {
          services.garage.loadBalancer.servers = [
            {
              url = "http://localhost:3900/";
            }
          ];

          middlewares = {
            auth = {
              basicAuth = {
                users = [
                  "thein3rovert:$apr1$R7282Dcn$A6VkhZibkhspsDhasYRXK1"
                ]; # Use hash for password using nix-shell -p apacheHttpd [htpasswd]
              };
            };
          };

          # === Routes ===
          routers = {
            api = {
              rule = "Host(`thein3rovert.dev`)";
              service = "api@internal";
              entryPoints = [ "websecure" ];
              middlewares = [ "auth" ]; # Activate auth for domain access
              # Configure TLS
              tls = {
                certResolver = "godaddy";
                domains = [
                  {
                    main = "thein3rovert.dev";
                    # sans = [ "*.thein3rovert.dev" ]; # Uncomment for wildcard
                  }
                ];
              };
            };
          };
          routers.garage = {
            rule = "Host(`s3.thein3rovert.dev`)";
            service = "garage";
            entryPoints = [ "websecure" ];
            tls = {
              certResolver = "godaddy";
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

    # Service configuration
    systemd.services.traefik = {
      serviceConfig = {
        EnvironmentFile = [ "${config.age.secrets.godaddy.path}" ];
        User = "traefik";
        Group = "traefik";
      };
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };

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
