# Homelab Base Configuration Module

Centralized configuration management for your NixOS homelab infrastructure.

## Overview

This module provides a unified configuration system for ports, storage, networking, containers, and host information across your homelab.

## Quick Reference

### 1. Ports

**Usage:**
```nix
# Container ports
config.homelab.containerPorts.traefik  # 8080

# Service ports
config.homelab.servicePorts.ssh  # 22

# Custom application ports
config.homelab.customPorts.api  # 4873
```

### 2. Storage

**Usage:**
```nix
# Container storage
config.homelab.containerStorage.traefik.path  # "/var/lib/containers/traefik"

# Service storage
config.homelab.servicesStorage.adguard.path  # "/var/lib/adguardhome"

# Create directories with systemd
systemd.tmpfiles.rules = [
  "d ${config.homelab.servicesStorage.traefik.path} ${config.homelab.servicesStorage.traefik.permissions} ${config.homelab.servicesStorage.traefik.owner} ${config.homelab.servicesStorage.traefik.group} -"
];
```

### 3. Networking

**Usage:**
```nix
# Host IPs
config.homelab.hosts.emily     # "10.10.10.12"
config.homelab.hosts.finn      # "10.10.10.10"

# Network configuration
config.homelab.networkInterface           # "eth0"
config.homelab.ipAddresses.host          # Primary host IP
config.homelab.ipAddresses.gateway       # "192.168.1.1"
config.homelab.ipAddresses.dnsServers    # ["1.1.1.1" "8.8.8.8"]
config.homelab.ipAddresses.subnet        # "192.168.1.0/24"

# Static IP assignments
config.homelab.ipAddresses.staticAssignments.nginx  # "192.168.1.20"
```

### 4. Containers

**Usage:**
```nix
# Container runtime settings
config.homelab.containers.runtime        # "podman"
config.homelab.containers.network        # "homelab"
config.homelab.containers.storageDriver  # "overlay2"

# Example: Configure container
virtualisation.oci-containers.backend = config.homelab.containers.runtime;
```

### 5. Host Information

**Usage:**
```nix
# Host metadata
config.homelab.hostInfo.hostname      # "homelab"
config.homelab.hostInfo.architecture  # "x86_64"
config.homelab.hostInfo.location      # "home"

# Example: Set hostname
networking.hostName = config.homelab.hostInfo.hostname;
```

### 6. User & Group

**Usage:**
```nix
config.homelab.baseUser  # "thein3rovert"
config.homelab.user      # "share"
config.homelab.group     # "share"
config.homelab.timeZone  # "Europe/London"
```

## Configuration Structure

```
modules/base/
├── default.nix      # Main options definitions
├── ports/           # Port configurations
├── storage/         # Storage path configurations
├── networks/        # Network configurations
├── containers/      # Container runtime configurations
└── readme.md        # This file
```

## Overriding Values

Override any value in your host-specific configuration:

```nix
# hosts/emily/configuration.nix
{
  homelab = {
    # Override host IP
    ipAddresses.host = config.homelab.hosts.emily;
    
    # Override network interface
    networkInterface = "ens18";
    
    # Add custom storage
    servicesStorage.myapp = {
      path = "/custom/path";
      owner = config.homelab.user;
      group = config.homelab.group;
      permissions = "755";
    };
    
    # Add custom ports
    containerPorts.myapp = 9000;
  };
}
```

## Enable Module

```nix
{
  homelab.enable = true;
}
```
