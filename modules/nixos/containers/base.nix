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
  options.myContainers = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable all my custom containers";
    };

    containers = mkOption {
      type = types.attrsOf (types.attrs);
      default = { };
      description = "Custom reusable container definations";
    };
  };

  config = mkIf config.myContainers.enable {
    virtualisation.oci-containers.containers = mkMerge (
      lib.mapAttrsToList (name: containerCfg: {
        "${name}" = {
          image = containerCfg.image or (throw "Missing 'image' for container ${name}");
          ports = containerCfg.ports or [ ];
          volumes = containerCfg.volumes or [ ];
          environment = containerCfg.environment or { };
          environmentFiles = containerCfg.environmentFiles or [ ];
        };
      }) config.myContainers.containers
    );
  };
}
