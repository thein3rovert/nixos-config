{ pkgs, ... }:
{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true; # When wi have th enable i can use either the docker or the podman command
      autoPrune = {
        # Things that are not needed will be deleted automatically
        enable = true;
        dates = "weekly";
        flags = [
          "--filter=until=24h"
          "--filter=label!=important"
        ];
      };
      defaultNetwork.settings.dns_enabled = true; # Dns enable for the container network
    };
  };

  # ===  TODO: Research on the user of custom network ===
  systemd.services.create-podman-networks = {
    wantedBy = [ "multi-user.target" ];
    after = [ "podman.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.podman}/bin/podman network exists web || \
      ${pkgs.podman}/bin/podman network create web --subnet=10.89.0.0/24 --internal
    '';
  };
  # Enable the Podman service
  environment.systemPackages = with pkgs; [ podman-compose ];
  users.users.thein3rovert-cloud.extraGroups = [
    "docker"
    "podman"
  ];
}
