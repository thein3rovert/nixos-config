{
  config,
  lib,
  ...
}:
let

  if-dockhand-enable = lib.mkIf config.nixosSetup.services.dockhand.enable;
  # create-linkding-containter = virtualisation.oci-containers."linkding";
  imageName = "fnsys/dockhand:latest";
  imageTag = "latest";
  host = "127.0.0.1";
  port = 3000;

  dataVolume = "dockhand_data:/app/data";
  socketVolume = "/run/podman/podman.sock:/var/run/docker.sock";
in
{
  options.nixosSetup.services.dockhand = {
    enable = lib.mkEnableOption "Docker Management and Monitoring Service";
  };

  config = if-dockhand-enable {
    virtualisation.oci-containers.containers.dockhand = {
      image = "${imageName}";
      ports = [ "${toString port}:3000" ];
      volumes = [
        dataVolume
        socketVolume
      ];
    };
  };

}
