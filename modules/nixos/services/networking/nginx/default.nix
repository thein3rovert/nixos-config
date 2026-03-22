{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkEnableOption
    types
    mkOption
    ;

  createOption = mkOption;
  mapAttribute = lib.mapAttrs;
  if-nginx-enable = mkIf config.nixosSetup.services.nginx.enable;
  cfg = config.nixosSetup.services.nginx;

  # Types used
  attributeSetOf = types.attrsOf;
  subModule = types.submodule;
  string = types.str;
  list = types.listOf;
  boolean = types.bool;
  port = types.port;

  # Variable
  serverName = "localhost";
  baseListenAddress = "0.0.0.0";
  basePort = 80;
in
{
  options.nixosSetup.services.nginx = {
    enable = mkEnableOption "Nginx Server";

    virtualHosts = mkOption {
      type = attributeSetOf (subModule {
        options = {

          root = createOption {
            type = string;
            default = "/var/www/${config.networking.hostName}";
            description = "Root directory for virtual host";
          };

          serverName = createOption {
            type = string;
            default = "${serverName}";
            description = "Server name from vitual host";
          };

          listenAddresses = createOption {
            type = list (subModule {
              options = {
                addr = createOption {
                  type = string;
                  default = "${baseListenAddress}";
                  description = "IP address to listen on";
                };

                port = createOption {
                  type = port;
                  default = basePort;
                  description = "Port to listen on";
                };
                ssl = mkOption {
                  type = boolean;
                  default = false;
                  description = "Enable SSL for this listener";
                };
              };
            });

            default = [
              {
                addr = "${baseListenAddress}";
                port = basePort;
                ssl = false;
              }
            ];
            description = "List of address and ports to listen on";
          };

          webPage = createOption {
            type = string;
            default = "index.html";
            description = "Simple Webpage";
          };

          webPageContent = createOption {
            type = string;
            default = ''
              <!DOCTYPE html>
              <html>
                <head><title> Welcome to ${config.networking.hostName}</title></head>
                <body>
                  <h1>Hello from ${config.networking.hostName}!</h1>
                  <p> Served from Nixos declarative config </p>
                </body>
              </html>
            '';
            description = "My Simple HomePage";
          };
        };
      });
      default = { };
      description = "Virtual Host Configuration";
    };
  };

  config = if-nginx-enable {
    services.nginx = {
      enable = true;

      virtualHosts = mapAttribute (name: vhostName: {
        serverName = vhostName.serverName;
        root = vhostName.root;
        listen = vhostName.listenAddresses;
        locations."/" = {
          index = vhostName.webPage;
        };
      }) cfg.virtualHosts;
    };

    # Create directories and symlink HTML files for each virtual host
    systemd.tmpfiles.rules = lib.flatten (
      lib.mapAttrsToList (name: vhost: [
        "d ${vhost.root} 0755 root root -"
        "L+ ${vhost.root}/${vhost.webPage} - - - - ${builtins.toFile "${name}-${vhost.webPage}" vhost.webPageContent}"
      ]) cfg.virtualHosts
    );
  };
}
