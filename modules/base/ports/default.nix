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
    };

    servicePorts = {
      adguard = 53;
      ssh = 22;
    };

    customPorts = {
      ipam = 5050;
      api = 4873;
    };
  };
}
