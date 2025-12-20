{ ... }:
{
  homelab = {
    containers = {
      # Container runtime configuration
      runtime = "podman";

      # Default container network
      network = "homelab";

      # Storage driver for containers
      storageDriver = "overlay2";
    };
  };
}
