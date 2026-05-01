{
  config,
  lib,
  ...
}:
let
  if-pgadmin-enable = lib.mkIf config.nixosSetup.services.pgadmin.enable;
  imageName = "dpage/pgadmin4:${imageTag}";
  imageTag = "latest";
  port = config.homelab.containerPorts.pgadmin;
  # pgAdmin volumes
  dataVolume = "/var/lib/pgadmin/data:/var/lib/pgadmin";
in
{
  options.nixosSetup.services.pgadmin = {
    enable = lib.mkEnableOption "pgAdmin - PostgreSQL management tool";
  };
  config = if-pgadmin-enable {
    virtualisation.oci-containers.containers.pgadmin = {
      image = imageName;
      ports = [ "${toString port}:80" ];
      volumes = [ dataVolume ];
      environment = {
        PGADMIN_DEFAULT_EMAIL = "admin@admin.com";
        PGADMIN_DEFAULT_PASSWORD = "admin123456";
      };
      extraOptions = [ "--cap-add=NET_BIND_SERVICE" ];
    };

    systemd.services.init-pgadmin-data = {
      description = "Initialize pgAdmin data directory";
      wantedBy = [ "podman-pgadmin.service" ];
      before = [ "podman-pgadmin.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/bin/sh -c 'mkdir -p /var/lib/pgadmin && chown -R 5050:5050 /var/lib/pgadmin'";
        RemainAfterExit = true;
      };
    };
  };
}
