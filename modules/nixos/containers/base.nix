# Base.nix
{ config, lib, ... }:
let
  # Need library functions
  inherit (lib)
    mkOption
    types
    mkIf
    mkMerge
    ;
in
{
  # imports = [ ./traefik.nix ];
  options.myContainers = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable all my custom containers";
    };

    # This is an attribute of attribute set (nested)
    containers = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            image = mkOption {
              type = types.str;
              description = "Container image";
            };

            ports = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Port mappings";
            };

            volumes = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Volume mappings";
            };

            environment = mkOption {
              type = types.attrsOf types.str;
              default = { };
              description = "Environment variables";
            };

            environmentFiles = mkOption {
              type = types.listOf types.path;
              default = [ ];
              description = "Environment files";
            };

            extraOptions = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Extra options for OCI container (e.g., --cap-add, --device)";
            };

            traefik = mkOption {
              type = types.nullOr (
                types.submodule {
                  options = {
                    enable = mkOption {
                      type = types.bool;
                      default = false;
                      description = "Enable Traefik for this container";
                    };

                    url = mkOption {
                      type = types.str;
                      description = "Backend URL for load balancer";
                      example = "http://localhost:8083/";
                    };

                    rule = mkOption {
                      type = types.str;
                      description = "Traefik router rule";
                      example = "Host(`freshrss.example.com`)";
                    };

                    entryPoints = mkOption {
                      type = types.listOf types.str;
                      default = [ ];
                      description = "Entry points (empty means use default)";
                    };

                    tls = mkOption {
                      type = types.submodule {
                        options = {
                          enable = mkOption {
                            type = types.bool;
                            default = true;
                            description = "Enable TLS";
                          };

                          certResolver = mkOption {
                            type = types.nullOr types.str;
                            default = null;
                            description = "Certificate resolver (null means use default)";
                          };

                          domains = mkOption {
                            type = types.nullOr (
                              types.listOf (
                                types.submodule {
                                  options = {
                                    main = mkOption {
                                      type = types.str;
                                      description = "Main domain";
                                    };
                                    sans = mkOption {
                                      type = types.listOf types.str;
                                      default = [ ];
                                      description = "Subject alternative names";
                                    };
                                  };
                                }
                              )
                            );
                            default = null;
                            description = "TLS domains configuration";
                          };
                        };
                      };
                      default = { };
                      description = "TLS configuration";
                    };

                    middlewares = mkOption {
                      type = types.nullOr (types.listOf types.str);
                      default = null;
                      description = "Traefik middlewares";
                    };

                    priority = mkOption {
                      type = types.nullOr types.int;
                      default = null;
                      description = "Router priority";
                    };
                  };
                }
              );
              default = null;
              description = "Traefik configuration";
            };
          };
        }
      );
      default = { };
      description = "Custom reusable container definitions";
    };
  };
  config = mkIf config.myContainers.enable {
    virtualisation.oci-containers.containers = mkMerge (

      lib.mapAttrsToList (containerName: containerCfg: {
        "${containerName}" = {
          # Common attr need for basic container
          image = containerCfg.image or (throw "Missing 'image' for container ${containerName}");
          ports = containerCfg.ports;
          volumes = containerCfg.volumes;
          environment = containerCfg.environment;
          environmentFiles = containerCfg.environmentFiles;
          extraOptions = containerCfg.extraOptions;
        };
      }) config.myContainers.containers
    );
  };
}
