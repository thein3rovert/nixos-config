# Homelab Services Base Layer Control

## Overview

This module provides a two-tier control system for managing services across your homelab infrastructure:

1. **Global Control**: Enable/disable all services across all hosts
2. **Per-Host Control**: Enable/disable services on specific hosts

## Architecture

The base services module connects to `modules/base/default.nix` and provides centralized control over all services defined in `nixosSetup.services.*`. This allows you to:

- Disable services globally during maintenance
- Control services per-host for different server roles
- Override host-specific service configurations from a base layer

## Configuration Options

### Global Master Switch

Located at: `homelab.services.enable`

```nix
homelab.services = {
  enable = true;  # Global switch for ALL hosts
};
```

### Per-Host Control

Located at: `homelab.services.hosts.<hostname>.enable`

```nix
homelab.services.hosts = {
  bellamy.enable = true;   # Enable services on Bellamy
  kira.enable = false;     # Disable services on Kira
  spike.enable = true;     # Enable services on Spike
};
```

## Usage Examples

### Example 1: Normal Operation (All Services Enabled)

```nix
# modules/base/default.nix or host config
{
  homelab = {
    enable = true;
    services = {
      enable = true;  # Global master switch: ON
      hosts = {
        bellamy.enable = true;   # Host-specific: ON
      };
    };
  };
}

# hosts/bellamy/default.nix
{
  networking.hostName = "Bellamy";
  
  nixosSetup.services = {
    memos.enable = true;      # ✅ Will be enabled
    traefik.enable = true;    # ✅ Will be enabled
    minio.enable = true;      # ✅ Will be enabled
  };
}
```

**Result**: All services run normally as configured.

---

### Example 2: Disable Services for Specific Host

```nix
# modules/base/default.nix or shared config
{
  homelab = {
    enable = true;
    services = {
      enable = true;  # Global master switch: ON
      hosts = {
        bellamy.enable = false;  # 🚫 Host-specific: OFF
        kira.enable = true;      # ✅ Other hosts still work
      };
    };
  };
}

# hosts/bellamy/default.nix
{
  networking.hostName = "Bellamy";
  
  nixosSetup.services = {
    memos.enable = true;      # ❌ FORCED to false
    traefik.enable = true;    # ❌ FORCED to false
    minio.enable = true;      # ❌ FORCED to false
  };
}
```

**Result**: Bellamy's services are all disabled, but other hosts continue running their services.

---

### Example 3: Global Shutdown (Maintenance Mode)

```nix
# modules/base/default.nix
{
  homelab = {
    enable = true;
    services = {
      enable = false;  # 🚫 Global master switch: OFF
      hosts = {
        bellamy.enable = true;   # Ignored when global is off
        kira.enable = true;      # Ignored when global is off
      };
    };
  };
}

# All hosts
{
  nixosSetup.services = {
    memos.enable = true;      # ❌ FORCED to false on ALL hosts
    traefik.enable = true;    # ❌ FORCED to false on ALL hosts
  };
}
```

**Result**: ALL services on ALL hosts are disabled regardless of individual settings.

---

### Example 4: Multi-Host Setup with Different Roles

```nix
# Shared configuration
{
  homelab = {
    enable = true;
    services = {
      enable = true;
      hosts = {
        # Production server - all services enabled
        bellamy.enable = true;
        bellamy.description = "Production application server";
        
        # Storage server - services disabled (only storage services run)
        kira.enable = false;
        kira.description = "Dedicated storage server";
        
        # Development server - services enabled
        spike.enable = true;
        spike.description = "Development and testing server";
      };
    };
  };
}
```

**Result**: Each host can have a different service profile based on its role.

---

## How It Works

### Control Flow

```
┌─────────────────────────────────────────────────┐
│  homelab.services.enable (Global)               │
│  - true: Check per-host settings               │
│  - false: Disable ALL services on ALL hosts    │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  homelab.services.hosts.<hostname>.enable       │
│  - true: Allow host services to run            │
│  - false: Disable ALL services on THIS host    │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  nixosSetup.services.<service>.enable           │
│  - Individual service settings in host config   │
│  - Only applies if both above are true         │
└─────────────────────────────────────────────────┘
```

### Technical Implementation

1. **Hostname Detection**: The module reads `config.networking.hostName` to determine which host is being configured

2. **Conditional Override**: Uses `mkForce` to override service settings when:
   - Global services are disabled (`homelab.services.enable = false`), OR
   - Host-specific services are disabled (`homelab.services.hosts.<hostname>.enable = false`)

3. **Fallback Behavior**: If a host is not defined in `homelab.services.hosts`, services are **enabled by default**

## Currently Managed Services

The following services are controlled by this base layer:

- `traefik` - Reverse proxy
- `tailscale` - VPN mesh network
- `linkding` - Bookmark manager
- `glance` - Dashboard
- `uptime-kuma` - Uptime monitoring
- `memos` - Note-taking
- `minio` - Object storage
- `hawser` - Custom service
- `garage-webui` - Garage S3 web interface
- `garage` - Distributed object storage

## Adding New Services

When you create a new service module, add it to the list in `modules/base/services/default.nix`:

```nix
config = mkIf (!cfg.enable || !hostServiceCfg.enable) {
  nixosSetup.services = mkForce {
    # ... existing services ...
    
    # Add your new service here
    your-new-service.enable = mkForce false;
  };
};
```

## Best Practices

### 1. Default State
- Keep `homelab.services.enable = true` by default
- Only set to `false` during maintenance or emergencies

### 2. Host-Specific Control
- Define per-host settings in a shared configuration file
- Document why specific hosts have services disabled

### 3. Testing New Configurations
- Disable services on a test host first
- Verify the configuration works before deploying to production

### 4. Maintenance Windows
```nix
# Before maintenance
homelab.services.hosts.bellamy.enable = false;

# Perform maintenance...

# After maintenance
homelab.services.hosts.bellamy.enable = true;
```

## Troubleshooting

### Services Won't Start

1. **Check Global Switch**
   ```nix
   homelab.services.enable = ?
   ```

2. **Check Host-Specific Switch**
   ```nix
   homelab.services.hosts.<your-hostname>.enable = ?
   ```

3. **Verify Hostname**
   ```bash
   hostname  # Should match the key in homelab.services.hosts
   ```

### Unexpected Behavior

- Remember: `mkForce` overrides ALL individual service settings
- Check if your hostname is correctly set in `networking.hostName`
- Verify the host is defined in `homelab.services.hosts`

## File Location

This module is located at:
```
modules/base/services/default.nix
```

And is imported in:
```
modules/base/default.nix
```

## Related Modules

- `modules/base/default.nix` - Main homelab configuration
- `modules/nixos/os/services/*` - Individual service definitions
- `hosts/*/default.nix` - Host-specific configurations

## Version History

- **v1.0** - Initial implementation with global and per-host control
