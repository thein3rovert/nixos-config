{
  config,
  ...
}:
let
  homelab = config.homelab;
in
{
  homelab = {
    containerPorts = {
      linkding = 5860;
      zerobyte = 4096;
      uptime-kuma = 8380;
      freshrss = 8083;
      jotty = 8382;
    };

    servicePorts = {
      traefik = 80;
      adguard = 53;
      ssh = 22;
      garage-api = 3900;
      # minio-console = 3007;
      minio = [
        3007
        3008
      ];
      # minio-api = 3008;
    };

    customPorts = {
      ipam = 5050;
      api = 4873;
    };
  };
}
