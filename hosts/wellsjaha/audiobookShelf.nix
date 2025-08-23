{ pkgs, lib, ... }:
{
  virtualisation.oci-containers.containers."audiobookshelf" = {
    image = "advplyr/audiobookshelf";
    ports = [ "0.0.0.0:3992:80" ]; # Local port mapping
    volumes = [

      # FIX: Change volume point
      "/home/thein3rovert/audiobookshelf/config:/config:rw"
      "/home/thein3rovert/audiobookshelf/metadata:/metadata:rw"
      "/home/thein3rovert/audiobookshelf/media:/audiobooks:ro"
    ];

  };
  systemd.services."podman-audiobookshelf" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    partOf = [
      "podman-compose-audiobookshelf-root.target"
    ];
    wantedBy = [
      "podman-compose-audiobookshelf-root.target"
    ];
  };
}
