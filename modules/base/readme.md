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

## Storage Configuration

- OPTION DEFINITION

```nix
    servicesStorage = createOption {
      type = attributeSetOf (
        types.submodule {
          options = {
            path = createOption {
              type = string;
              description = "Path to the Volume";
            };

            owner = createOption {
              type = string;
              default = cfg.baseUser;
              description = "Owner of the volume";
            };

            group = createOption {
              type = string;
              default = cfg.group;
              description = "Group of the volume";
            };

            permissions = createOption {
              type = string;
              default = "755";
              description = "Permissions for the volume";
            };
          };
        }
      );
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
    servicesStorage = {
      traefik = {
        path = "/var/lib/traefik";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      linkding = {
        path = "/var/lib/linkding";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };

      media = {
        path = "/srv/media";
        owner = homelab.user;
        group = homelab.group;
        permissions = "755";
      };
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
