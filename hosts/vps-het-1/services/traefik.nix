{ config, pkgs, ... }:
{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      log = {
        level = "DEBUG";
      };
      api = {
        dashboard = true; # Enable dashboard

        # Enable insecure when in testng
        # Disable insecure in production
        insecure = false;

      };

      providers.docker = {
        endpoint = "unix:///run/podman/podman.sock";
        exposedByDefault = false;
        network = "traefik_proxy"; # Network Traefik will use
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
              propagation.delayBeforeChecks = 300; # TODO: Change to 90 or 180
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
        # Add middleware
        middlewares = {
          auth = {
            basicAuth = {
              users = [
                "thein3rovert:$apr1$RQ3pKhvo$z0iAMofUnV735jTowvP2T1"
              ]; # Use hash for password using nix-shell -p apacheHttpd [htpasswd]
            };
          };
        };

        # Routing handler
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

        # Optional: Add security middleware
        # middlewares = {
        #   secHeaders = {
        #     headers = {
        #       forceSTSHeader = true;
        #       stsSeconds = 31536000;
        #       stsIncludeSubdomains = true;
        #       stsPreload = true;
        #     };
        #   };
        # };
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

    # Use h-nix to encrypt the secret later
    # traefikEnv = {
    #   text = ''
    #     echo "Creating Traefik env file..."
    #     cat > /var/lib/traefik/env << 'EOF'
    #     GODADDY_API_KEY=<API-KEY>
    #     GODADDY_API_SECRET=<API-SECRET>
    #     EOF
    #     chmod 600 /var/lib/traefik/env
    #   '';
    #   deps = [ "traefikDirectories" ];
    # };

  };

  # Service configuration
  systemd.services.traefik = {
    serviceConfig = {
      EnvironmentFile = [ "${config.age.secrets.traefik.path}" ];
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
}
