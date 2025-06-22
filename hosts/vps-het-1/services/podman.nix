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
  # Enable the Podman service
  systemd.services.podman.wantedBy = [ "multi-user.target" ];
  environment.systemPackages = with pkgs; [ podman-compose ];
  users.users.thein3rovert-cloud.extraGroups = [
    "docker"
    "podman"
  ];
}
