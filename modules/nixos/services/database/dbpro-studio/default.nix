{
  config,
  lib,
  ...
}:
let
  if-dbpro-studio-enable = lib.mkIf config.nixosSetup.services.dbpro-studio.enable;
  imageName = "ghcr.io/dbprohq/dbpro-studio:${imageTag}";
  imageTag = "latest";
  port = config.homelab.containerPorts.dbpro-studio;
  # DBPro Studio volumes
  dataVolume = "/var/lib/dbpro-studio:/data";
  dbVolume = "/home/thein3rovert/Documents/project/lifeos:/mnt/lifeos";
in
{
  options.nixosSetup.services.dbpro-studio = {
    enable = lib.mkEnableOption "DBPro Studio - Full-featured database workspace";
  };
  config = if-dbpro-studio-enable {
    virtualisation.oci-containers.containers.dbpro-studio = {
      image = imageName;
      ports = [ "${toString port}:3100" ];
      volumes = [ dataVolume dbVolume ];
      user = "root:root";
    };

    systemd.services.init-dbpro-studio-data = {
      description = "Initialize DBPro Studio data directory";
      wantedBy = [ "podman-dbpro-studio.service" ];
      before = [ "podman-dbpro-studio.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c 'mkdir -p /var/lib/dbpro-studio && chmod -R 777 /var/lib/dbpro-studio && chmod -R 777 /home/thein3rovert/Documents/project/lifeos'";
        RemainAfterExit = true;
      };
    };
  };
}
