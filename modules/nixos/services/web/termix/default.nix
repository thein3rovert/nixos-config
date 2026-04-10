{
  config,
  lib,
  ...
}:
let
  if-termix-enable = lib.mkIf config.nixosSetup.services.termix.enable;

  imageName = "ghcr.io/lukegus/termix:${imageTag}";
  imageTag = "latest";
  port = config.homelab.containerPorts.termix;

  # Termix volumes
  dataVolume = "/var/lib/termix/data:/app/data";
in
{
  options.nixosSetup.services.termix = {
    enable = lib.mkEnableOption "Termix SSH Management Service";
  };

  config = if-termix-enable {
    virtualisation.oci-containers.containers.guacd = {
      image = "guacamole/guacd:latest";
      ports = [
        "4822:4822"
      ];
    };

    virtualisation.oci-containers.containers.termix = {
      image = imageName;
      ports = [
        "${toString port}:8080"
      ];
      volumes = [
        dataVolume
      ];
      environment = {
        PORT = "8080";
      };
      dependsOn = [ "guacd" ];
    };
  };
}
