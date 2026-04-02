{
  config,
  lib,
  ...
}:
let
  if-kestra-enable = lib.mkIf config.nixosSetup.services.kestra.enable;

  imageName = "kestra/kestra:${imageTag}";
  imageTag = "latest";
  port = config.homelab.containerPorts.kestra;

  # PostgreSQL connection
  postgresHost = config.homelab.ipAddresses.emily.tailscaleIp;
  postgresPort = config.homelab.servicePorts.postgresql;

  # Kestra volumes
  dataVolume = "/var/lib/kestra/data:/app/storage";
  dockerVolume = "/var/run/podman/podman.sock:/var/run/docker.sock";
  tmpVolume = "/tmp/kestra-wd:/tmp/kestra-wd";
in
{
  options.nixosSetup.services.kestra = {
    enable = lib.mkEnableOption "Kestra Workflow Orchestration";
  };

  config = if-kestra-enable {
    virtualisation.oci-containers.containers.kestra = {
      image = imageName;
      ports = [
        "${toString port}:8080"
        "8081:8081"
      ];
      volumes = [
        dataVolume
        dockerVolume
        tmpVolume
      ];
      user = "root";
      cmd = [
        "server"
        "standalone"
        "--worker-thread=128"
      ];
      environment = {
        KESTRA_CONFIGURATION = ''
          datasources:
            postgres:
              url: jdbc:postgresql://${postgresHost}:${toString postgresPort}/kestra
              driver-class-name: org.postgresql.Driver
              username: kestra
              password: $(cat ${config.age.secrets.kestra-db.path})
          kestra:
            server:
              basic-auth:
                enabled: true
                username: $(cat ${config.age.secrets.kestra-user.path})
                password: $(cat ${config.age.secrets.kestra-password.path})
            repository:
              type: postgres
            storage:
              type: local
              local:
                base-path: "/app/storage"
            queue:
              type: postgres
            tasks:
              tmp-dir:
                path: /tmp/kestra-wd/tmp
            url: http://localhost:${toString port}/
        '';
      };
    };
  };
}
