{ config, lib, ... }:
{
  virtualisation.oci-containers = {
    containers = {

      "audiobookshelf-ts" = {
        image = "tailscale/tailscale:latest";
        hostname = "audiobooks";
        environment = {
          # "TS_AUTHKEY" = "ts-authKey";
          "TS_SERVE_CONFIG" = "/config/audiobookshelf.json";
          "TS_STATE_DIR" = "/var/lib/tailscale";
          "TS_USERSPACE" = "true";
        };
        environmentFiles = [ config.age.secrets.audiobookshelf.path ];
        volumes = [
          "/home/thein3rovert/audiobookshelf/ts-config:/config:rw"
          "/home/thein3rovert/audiobookshelf/ts-state:/var/lib/tailscale:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--hostname=audiobooks"
          "--network-alias=audiobookshelf-ts"
        ];
      };

      "audiobookshelf" = {
        image = "advplyr/audiobookshelf";
        ports = [ "0.0.0.0:3992:80" ]; # Local port mapping
        volumes = [

          #FIX: Change volume point
          "/home/thein3rovert/audiobookshelf/config:/config:rw"
          "/home/thein3rovert/audiobookshelf/metadata:/metadata:rw"
          "/home/thein3rovert/audiobookshelf/media:/audiobooks:ro"
        ];

        # Network mode - sharing network with another container
        # Shares the network stack with the Tailscale container
        extraOptions = [
          "--network=container:audiobookshelf-ts"
        ];
        # Fixes dependencies issues
        dependsOn = [ "audiobookshelf-ts" ];
      };
      #
    };
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
