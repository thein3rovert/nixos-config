# HOMELAB BASE CONFIGURATIONS

> Homelab(default.nix) -> [configs] -> usage

> [!EXAMPLE]

```nix
    # Port to be used by homelab
    containerPorts = createOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Ports used by Nixos Podman Containers";
    };
    servicePorts = createOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Ports used by Nixos Services";
    };
    customPorts = createOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Ports used by custom Services and Applications";
    };
```

- CONFIG

```nix
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
