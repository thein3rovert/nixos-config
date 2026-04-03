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

  # Kestra volumes
  dataVolume = "/var/lib/kestra/data:/app/storage";
  dockerVolume = "/var/run/podman/podman.sock:/var/run/docker.sock";
  tmpVolume = "/tmp/kestra-wd:/tmp/kestra-wd";
  configVolume = "/var/lib/kestra/config.yaml:/app/config.yaml:ro";
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
        "8081:8081" # Helth check for /health /prometheus (Remain internal)
      ];
      volumes = [
        dataVolume
        dockerVolume
        tmpVolume
        configVolume
      ];
      user = "root";
      cmd = [
        "server"
        "standalone"
        "--worker-thread=128"
        "--config"
        "/app/config.yaml"
      ];
    };
  };
}
