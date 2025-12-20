# HOMELAB BASE CONFIGURATIONS

> Homelab(default.nix) -> [configs] -> usage

- USAGE

```nix
# Example: Reference a port in your service configuration
services.traefik.port = config.homelab.containerPorts.traefik;

# Example: Reference a storage path in your service configuration
services.traefik.dataDir = config.homelab.servicesStorage.traefik.path;

# Example: Use storage configuration for systemd tmpfiles
systemd.tmpfiles.rules = [
  "d ${config.homelab.servicesStorage.traefik.path} ${config.homelab.servicesStorage.traefik.permissions} ${config.homelab.servicesStorage.traefik.owner} ${config.homelab.servicesStorage.traefik.group} -"
];
```

```nix
# Access host information
config.homelab.hostInfo.hostname      # Returns "homelab"
config.homelab.hostInfo.architecture  # Returns "x86_64"
config.homelab.hostInfo.location      # Returns "home"

# Example usage
networking.hostName = config.homelab.hostInfo.hostname;
# Or in conditional logic based on architecture/location
```

Essential Categories:

1. Network Configuration

IP addresses (host, gateway, static assignments)
DNS servers
Subnets/CIDR
VPN settings
Network interfaces

2. Storage & Volumes

Volume paths and types (ZFS, BTRFS, etc.)
Mount points and options
Storage quotas/sizes
Backup locations
Media/data/config/cache directories

3. Port Management

Container ports
Service ports
Port ranges
Reserved ports

4. User & Permissions

Default service user/group
Per-service overrides
Directory permissions

5. SSL/TLS

Certificate provider
ACME email
Certificate directories

6. Monitoring & Logging

Log levels
Retention policies
Metrics ports

7. Backup Configuration

Schedules
Retention periods
Remote destinations

8. Authentication

SSO provider settings
OAuth configurations

9. Container Runtime

Runtime choice (Docker/Podman)
Network settings
Storage driver

10. Host Information

Hostname
Architecture
Physical location
