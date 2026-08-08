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
        "--worker-thread=4" # Change from 128 -> 4
        "--config"
        "/app/config.yaml"
      ];
      extraOptions = [
        "--memory=2048m"
        "--memory-swap=2048m"
        # Health check configuration - monitors /health endpoint and restarts on failure
        # When Postgres becomes unavailable, Kestra stays running but becomes unhealthy
        # Health check detects this and triggers container restart
        "--health-cmd=curl -f http://localhost:8081/health || exit 1"
        "--health-interval=30s" # Check every 30 seconds
        "--health-retries=3" # Fail after 3 consecutive failures
        "--health-start-period=60s" # Give Kestra 60s to start before health checks begin
        "--restart=on-failure" # Restart container when unhealthy
      ];
    };
  };
}
