{
  config,
  lib,
  ...
}:
let

  if-fileshare-enable = lib.mkIf config.nixosSetup.services.fileshare.enable;
  # create-linkding-containter = virtualisation.oci-containers."linkding";
  imageName = "fnsys/dockhand:latest";
  imageTag = "latest";
  host = "127.0.0.1";
  port = 3000;

  dataVolume = "dockhand_data:/app/data";
  socketVolume = "/run/podman/podman.sock:/var/run/docker.sock";
in
{
  options.nixosSetup.services.fileshare = {
    enable = lib.mkEnableOption "File sharing Service";
  };

  config = if-fileshare-enable {
    virtualisation.oci-containers.containers.fileshare = {
      image = "${imageName}";
      ports = [ "${toString port}:3000" ];
      volumes = [
        dataVolume
        socketVolume
      ];
    };
  };

}
