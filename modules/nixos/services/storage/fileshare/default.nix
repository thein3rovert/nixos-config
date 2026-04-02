{
  config,
  lib,
  ...
}:
let

  if-fileshare-enable = lib.mkIf config.nixosSetup.services.fileshare.enable;

  imageName = "gtstef/filebrowser:${imageTag}";
  imageTag = "stable";
  port = 8900;

  # FileBrowser volumes
  dataVolume = "/var/lib/filebrowser/data:/home/filebrowser/data";
  filesVolume = "/var/lib/filebrowser/files:/files";
  config-file = "/etc/filebrowser/config.yaml:/home/filebrowser/data/config.yaml:ro";
in
{
  options.nixosSetup.services.fileshare = {
    enable = lib.mkEnableOption "File sharing Service";
  };

  config = if-fileshare-enable {
    virtualisation.oci-containers.containers.fileshare = {
      image = "${imageName}";
      ports = [ "${toString port}:80" ];
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
