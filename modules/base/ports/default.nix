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
      traefik = 8080;
      linkding = 5860;
      zerobyte = 4096;
    };

    servicePorts = {
      adguard = 53;
      ssh = 22;
      garage-api = 3900;
    };

    customPorts = {
      ipam = 5050;
      api = 4873;
    };
  };
}
