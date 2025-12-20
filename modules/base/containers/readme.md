## Usage
# Access container runtime
config.homelab.containers.runtime  # Returns "podman"

# Access container network
config.homelab.containers.network  # Returns "homelab"

# Access storage driver
config.homelab.containers.storageDriver  # Returns "overlay2"

# Example usage in a container configuration
virtualisation.oci-containers.backend = config.homelab.containers.runtime;
virtualisation.oci-containers.containers.myapp.extraOptions = [ "--network=${config.homelab.containers.network}" ];
