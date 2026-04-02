{
  config,
  lib,
  ...
}:
let

  if-fileshare-enable = lib.mkIf config.nixosSetup.services.fileshare.enable;
  # create-linkding-containter = virtualisation.oci-containers."linkding";
  imageName = "gtstef/filebrowser:${imageTag}";
  imageTag = "stable";
  port = 8900;

  # FileBrowser volumes
  dataVolume = "/var/lib/filebrowser/data:/home/filebrowser/data";
  filesVolume = "/var/lib/filebrowser/files:/files";
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
        filesVolume
      ];
      environment = {
        FILEBROWSER_CONFIG = "data/config.yaml";
      };
    };
  };

}
