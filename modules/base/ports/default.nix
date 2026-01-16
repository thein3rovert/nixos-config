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
      traefik = 80;
      linkding = 5860;
      zerobyte = 4096;
      uptime-kuma = 8380;
      freshrss = 8083;
      jotty = 8382;
    };

    servicePorts = {
      adguard = 53;
      ssh = 22;
      garage-api = 3900;
      minio-console = 3007;
      minio-api = 3008;
    };

    customPorts = {
      ipam = 5050;
      api = 4873;
    };
  };
}
