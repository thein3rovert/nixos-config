# Exposing Services Over LAN with Traefik

This guide explains how to expose a local service (container or NixOS service) over your LAN using Traefik reverse proxy with custom domain names.

## Architecture Overview

The system uses a centralized configuration approach with four main components:

1. **Ports Configuration** - Defines all port numbers
2. **Network Map** - Maps services to hostnames, ports, and virtual hosts
3. **IP Registry** - Combines IPs and ports to create service URLs
4. **Traefik** - Reverse proxy that routes traffic based on domain names

```
┌─────────────────┐
│ Ports Config    │ ──┐
└─────────────────┘   │
                      ├──► ┌─────────────────┐      ┌─────────────────┐
┌─────────────────┐   │    │  Network Map    │ ───► │  IP Registry    │
│ IP Addresses    │ ──┘    └─────────────────┘      └─────────────────┘
└─────────────────┘                                           │
                                                              │
                                                              ▼
                                                    ┌─────────────────┐
                                                    │    Traefik      │
                                                    └─────────────────┘
                                                              │
                                                              ▼
                                                    service.local.domain
```

## Step-by-Step Guide

### 1. Define Port in Ports Configuration

**File:** `modules/base/networks/default.nix`

Add your service port under either `containerPorts` (for Podman containers) or `servicePorts` (for NixOS services):

```nix
config.homelab = {
  containerPorts = {
    # ... other ports
    filebrowser = 8900;  # Add your container port here
  };

  servicePorts = {
    # ... other ports
    myservice = 3000;  # Or add your service port here
  };
};
```

### 2. Add Service to Network Map

**File:** `modules/snippets/networkMap/default.nix`

Add your service with hostname, port reference, and virtual host:

```nix
localNetworkMap = {
  # ... other services
  filebrowser = {
    hostName = "emily";  # Server/container name from IP addresses
    port = ports.containerPorts.filebrowser;  # Reference to port defined in step 1
    vHost = "filebrowser.${config.myDns.networkMap.name}";  # Domain name
  };
};
```

### 3. Register Service in IP Registry

**File:** `modules/base/networks/ip-registry.nix`

Add your service to create the full URL:

```nix
config.homelab.ipRegistry = {
  # ... other services
  filebrowser = {
    ip = hosts.emily.ip;  # Reference to IP from ip-addresses.nix
    port = networkMap.filebrowser.port;  # Reference to port from network map
    url = "${config.homelab.ipRegistry.filebrowser.ip}:${toString config.homelab.ipRegistry.filebrowser.port}";
  };
};
```

### 4. Configure Traefik Routes

**File:** `modules/nixos/services/networking/traefikk/default.nix`

Add both the service backend and the router:

```nix
dynamicConfigOptions = {
  http = {
    # Define the backend service
    services.filebrowser.loadBalancer.servers = [
      { url = "http://${config.homelab.ipRegistry.filebrowser.url}/"; }
    ];

    routers = {
      # ... other routers
      # Define the routing rule
      filebrowser = {
        rule = "Host(`${config.myDns.networkMap.localNetworkMap.filebrowser.vHost}`)";
        service = "filebrowser";
        entryPoints = [ "web" ];
      };
    };
  };
};
```

### 5. Update Your Service Configuration

Update your service to use the port from config instead of hardcoding it:

```nix
let
  port = config.homelab.containerPorts.filebrowser;  # Use centralized port
in
{
  virtualisation.oci-containers.containers.myservice = {
    ports = [ "${toString port}:80" ];
    # ... rest of config
  };
}
```

## File Locations Reference

- **Ports Config:** `modules/base/networks/default.nix`
- **IP Addresses:** `modules/base/networks/ip-addresses.nix`
- **IP Registry:** `modules/base/networks/ip-registry.nix`
- **Network Map:** `modules/snippets/networkMap/default.nix`
- **Traefik Config:** `modules/nixos/services/networking/traefikk/default.nix`

## Verification

After rebuilding NixOS:

1. Check Traefik dashboard at `http://traefik.yourdomain.local`
2. Verify your service appears in the routers list
3. Access your service via the configured domain: `http://servicename.yourdomain.local`

## Example: Complete FileBrowser Setup

Here's the complete flow for exposing FileBrowser:

**1. Port (default.nix):**
```nix
containerPorts.filebrowser = 8900;
```

**2. Network Map (networkMap/default.nix):**
```nix
filebrowser = {
  hostName = "emily";
  port = ports.containerPorts.filebrowser;
  vHost = "filebrowser.${config.myDns.networkMap.name}";
};
```

**3. IP Registry (ip-registry.nix):**
```nix
filebrowser = {
  ip = hosts.emily.ip;  # 10.10.10.12
  port = networkMap.filebrowser.port;  # 8900
  url = "${config.homelab.ipRegistry.filebrowser.ip}:${toString config.homelab.ipRegistry.filebrowser.port}";
};
```

**4. Traefik (traefikk/default.nix):**
```nix
services.filebrowser.loadBalancer.servers = [
  { url = "http://${config.homelab.ipRegistry.filebrowser.url}/"; }
];

routers.filebrowser = {
  rule = "Host(`${config.myDns.networkMap.localNetworkMap.filebrowser.vHost}`)";
  service = "filebrowser";
  entryPoints = [ "web" ];
};
```

**Result:** FileBrowser accessible at `http://filebrowser.yourdomain.local`

## Benefits of This Approach

- **Centralized Configuration:** All ports, IPs, and routes defined in one place
- **Type Safety:** NixOS validates all references at build time
- **No Duplication:** Port numbers defined once, referenced everywhere
- **Easy Maintenance:** Change a port in one place, updates everywhere
- **Self-Documenting:** Network map shows all services and their locations
