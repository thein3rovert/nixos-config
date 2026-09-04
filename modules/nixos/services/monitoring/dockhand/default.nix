{
  config,
  lib,
  ...
}:
let

  if-dockhand-enable = lib.mkIf config.nixosSetup.services.dockhand.enable;
  # create-linkding-containter = virtualisation.oci-containers."linkding";
  imageTag = "latest";
  imageName = "fnsys/dockhand:${imageTag}";
  port = 3000;
  dockhand_data = "/var/lib/containers/dockhand";

  dataVolume = "${dockhand_data}:/app/data";
  socketVolume = "/run/podman/podman.sock:/var/run/docker.sock";
in
{
  options.nixosSetup.services.dockhand = {
    enable = lib.mkEnableOption "Docker Management and Monitoring Service";
  };

  config = if-dockhand-enable {
    virtualisation.oci-containers.containers.dockhand = {
      image = "${imageName}";
      ports = [ "${toString port}:${toString port}" ];
      volumes = [
        dataVolume
        socketVolume
      ];
    };
  };

}
