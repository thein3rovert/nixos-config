# Homelab Services Base Layer Control

## Overview

This module provides a two-tier control system for managing services across your homelab infrastructure:

1. **Global Control**: Enable/disable all services across all hosts
2. **Per-Host Control**: Enable/disable services on specific hosts

## Architecture

The base services module follows a separation of concerns pattern:

- **Options Declaration**: All options are declared in `modules/base/default.nix` (the master configuration file)
- **Configuration Logic**: The actual control logic is implemented in `modules/base/services/default.nix`

This design ensures:
- All option declarations live in the master `base/default.nix` file
- Service control logic is modular and separate
- Centralized control over all services defined in `nixosSetup.services.*`
- Easy maintenance and understanding of the homelab structure

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

## File Structure

```
modules/base/
├── default.nix              # Master file - contains ALL option declarations
│                            # Including homelab.services options
└── services/
    ├── default.nix          # Service control logic only (no options)
    └── README.md            # This file
```

**Key Point**: Options are declared in the master `modules/base/default.nix`, while the logic to enforce those options is in `modules/base/services/default.nix`.

---

## Usage Examples

### Example 1: Basic Setup in Shared Configuration

```nix
# In a shared config file or directly in modules/base/default.nix
{
  homelab = {
    enable = true;
    
    services = {
      enable = true;  # Global master switch: ON
      
      hosts = {
        bellamy = {
          enable = true;
          description = "Production application server";
        };
      };
    };
  };
}
```

Then in your host configuration:

```nix
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

### Example 2: Multiple Hosts with Different Roles

```nix
# Shared configuration
{
  homelab = {
    enable = true;
    
    services = {
      enable = true;
      
      hosts = {
        # Production server - all services enabled
        bellamy = {
          enable = true;
          description = "Production application server";
        };
        
        # Storage server - services disabled
        kira = {
          enable = false;
          description = "Dedicated storage server - no web services";
        };
        
        # Development server - services enabled
        spike = {
          enable = true;
          description = "Development and testing server";
        };
      };
    };
  };
}
```

**Result**: 
- Bellamy: ✅ All services run
- Kira: ❌ All services disabled (storage only)
- Spike: ✅ All services run

---

### Example 3: Maintenance Mode - Disable Specific Host

```nix
# Before maintenance on Bellamy
{
  homelab.services.hosts.bellamy.enable = false;  # 🚫 Disable Bellamy services
}
```

```nix
# hosts/bellamy/default.nix
{
  nixosSetup.services = {
    memos.enable = true;      # ❌ FORCED to false
    traefik.enable = true;    # ❌ FORCED to false
    minio.enable = true;      # ❌ FORCED to false
  };
}
```

**Result**: Bellamy's services are all disabled. Other hosts continue running.

After maintenance, set back to `enable = true` and rebuild.

---

### Example 4: Global Shutdown (Emergency Maintenance)

```nix
{
  homelab.services.enable = false;  # 🚫 Global kill switch
  
  # All host-specific settings are ignored
  services.hosts = {
    bellamy.enable = true;   # Ignored
    kira.enable = true;      # Ignored
  };
}
```

**Result**: ALL services on ALL hosts are disabled regardless of individual settings.

---

## How It Works

### Control Flow

```
┌─────────────────────────────────────────────────┐
│  homelab.services.enable (Global)               │
│  Declared in: modules/base/default.nix         │
│  - true: Check per-host settings               │
│  - false: Disable ALL services on ALL hosts    │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  homelab.services.hosts.<hostname>.enable       │
│  Declared in: modules/base/default.nix         │
│  - true: Allow host services to run            │
│  - false: Disable ALL services on THIS host    │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│  nixosSetup.services.<service>.enable           │
│  Individual service settings in host config     │
│  - Only applies if both above are true         │
└─────────────────────────────────────────────────┘
```

### Technical Implementation

1. **Options Declaration** (`modules/base/default.nix`):
   - Declares `homelab.services.enable` - Global switch
   - Declares `homelab.services.hosts.<hostname>` - Per-host switches
   - All options live in the master configuration file

2. **Configuration Logic** (`modules/base/services/default.nix`):
   - Reads `config.networking.hostName` to identify the current host
   - Checks if global services are enabled
   - Checks if host-specific services are enabled
   - Uses `mkForce` to override service settings when disabled

3. **Fallback Behavior**: 
   - If a host is not defined in `homelab.services.hosts`, services are **enabled by default**

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

When you create a new service module, add it to the controlled services list in `modules/base/services/default.nix`:

```nix
config = mkIf (!cfg.enable || !hostServiceCfg.enable) {
  nixosSetup.services = mkForce {
    # ... existing services ...
    
    # Add your new service here
    your-new-service.enable = mkForce false;
  };
};
```

**Note**: No changes needed in `modules/base/default.nix` - all service-specific configuration is in the services module.

## Best Practices

### 1. Declare Options in Master File
- All `homelab.*` options belong in `modules/base/default.nix`
- Keep the master file as the single source of truth for options

### 2. Default State
- Keep `homelab.services.enable = true` by default
- Only set to `false` during maintenance or emergencies

### 3. Host-Specific Control
- Define all hosts in `homelab.services.hosts` in your shared configuration
- Document why specific hosts have services disabled using the `description` field

### 4. Testing New Configurations
- Disable services on a test host first
- Verify the configuration works before deploying to production

### 5. Maintenance Windows
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

3. **Verify Hostname Match**
   ```bash
   hostname  # Should match the key in homelab.services.hosts
   ```
   
   Example: If `networking.hostName = "Bellamy"`, then use:
   ```nix
   homelab.services.hosts.bellamy.enable = true;  # Note: Nix uses lowercase
   ```

### Unexpected Service Behavior

- Remember: `mkForce` overrides ALL individual service settings when services are disabled
- Check if your hostname is correctly set in `networking.hostName`
- Verify the host is defined in `homelab.services.hosts` (if not defined, defaults to enabled)

---

## File Locations

### Master Configuration (Options)
```
modules/base/default.nix
```
Contains the `homelab.services` options declaration

### Service Control Logic (Config)
```
modules/base/services/default.nix
```
Implements the control logic that enforces service enable/disable behavior

The services module is automatically imported by `modules/base/default.nix`.

---

## Version History

- **v1.1** - Refactored to separate options (in base/default.nix) from logic (in services/default.nix)
- **v1.0** - Initial implementation with global and per-host control
