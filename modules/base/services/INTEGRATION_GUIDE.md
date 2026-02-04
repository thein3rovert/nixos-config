# Integration Guide: Adding Base Services Control to Your Homelab

## Quick Start

### Step 1: Add to Your Shared Configuration

If you have a shared configuration file that all hosts import, add this:

```nix
# In your shared config or flake.nix
{
  homelab = {
    enable = true;
    
    services = {
      enable = true;  # Master switch for all hosts
      
      hosts = {
        bellamy.enable = true;
        # Add other hosts as needed
      };
    };
  };
}
```

### Step 2: Update Your Host Configuration

Your existing host configuration in `hosts/bellamy/default.nix` doesn't need to change:

```nix
{
  networking.hostName = "Bellamy";
  
  # These services will be controlled by the base layer
  nixosSetup.services = {
    traefik.enable = true;
    memos.enable = true;
    minio.enable = true;
    # ... all your existing services
  };
}
```

## Integration Patterns

### Pattern 1: Centralized Control (Recommended)

Create a shared configuration file:

```nix
# shared/homelab-services.nix
{ ... }:
{
  homelab.services = {
    enable = true;
    
    hosts = {
      bellamy = {
        enable = true;
        description = "Production server";
      };
      kira = {
        enable = false;
        description = "Storage only";
      };
    };
  };
}
```

Then import it in your flake or host configs:

```nix
# In your flake.nix or host config
imports = [
  ./shared/homelab-services.nix
];
```

### Pattern 2: Per-Host Override

Keep defaults in shared config, override in specific hosts:

```nix
# shared/default.nix
{ homelab.services.enable = true; }

# hosts/bellamy/default.nix
{
  homelab.services.hosts.bellamy.enable = true;
  
  nixosSetup.services = {
    # Your services here
  };
}

# hosts/kira/default.nix
{
  homelab.services.hosts.kira.enable = false;
  # No services will run on kira
}
```

### Pattern 3: Environment-Based Control

Use different settings for different environments:

```nix
# environments/production.nix
{ homelab.services.enable = true; }

# environments/maintenance.nix
{ homelab.services.enable = false; }
```

## Testing Your Setup

### Test 1: Verify Normal Operation

```bash
# Build your configuration
sudo nixos-rebuild test

# Check if services are running
systemctl status docker-memos.service
systemctl status docker-traefik.service
```

### Test 2: Disable Services for Your Host

```nix
# In your config
homelab.services.hosts.bellamy.enable = false;
```

```bash
# Rebuild
sudo nixos-rebuild test

# Verify services are stopped
systemctl status docker-memos.service
# Should show: Loaded: masked
```

### Test 3: Global Shutdown

```nix
homelab.services.enable = false;
```

```bash
# Rebuild and verify all services are disabled
sudo nixos-rebuild test
```

## Common Integration Scenarios

### Scenario 1: Adding to Existing Homelab

You already have hosts configured. Here's how to integrate:

1. **Add to shared config**:
   ```nix
   homelab.services = {
     enable = true;
     hosts = {
       # List all your existing hosts
       bellamy.enable = true;
       # ... others
     };
   };
   ```

2. **No changes needed** to individual host configs

3. **Deploy gradually** by setting hosts to `enable = true` one at a time

### Scenario 2: New Host Setup

Adding a new host named "jet":

1. **Add to homelab services**:
   ```nix
   homelab.services.hosts.jet = {
     enable = true;
     description = "New monitoring server";
   };
   ```

2. **Create host config**:
   ```nix
   # hosts/jet/default.nix
   {
     networking.hostName = "jet";
     nixosSetup.services = {
       # Your services
     };
   }
   ```

3. **Services automatically controlled** by base layer

### Scenario 3: Maintenance Window

Before maintenance:

```nix
# Option A: Disable specific host
homelab.services.hosts.bellamy.enable = false;

# Option B: Disable all services
homelab.services.enable = false;
```

Deploy with `sudo nixos-rebuild switch`

After maintenance, set back to `true` and redeploy.

## Migration Checklist

- [ ] Module is imported in `modules/base/default.nix`
- [ ] `homelab.enable = true` is set
- [ ] `homelab.services.enable = true` is set
- [ ] Each host is defined in `homelab.services.hosts.<hostname>`
- [ ] `networking.hostName` matches the key in `homelab.services.hosts`
- [ ] Tested with services enabled
- [ ] Tested with services disabled
- [ ] Documented in your infrastructure docs

## Troubleshooting Integration

### Issue: Services still running when disabled

**Check**:
1. Is `networking.hostName` correct?
   ```bash
   hostname  # Output should match config
   ```

2. Is the hostname defined in `homelab.services.hosts`?
   ```bash
   # Check your config
   grep -r "services.hosts" /etc/nixos/
   ```

3. Rebuild with:
   ```bash
   sudo nixos-rebuild switch --show-trace
   ```

### Issue: Services not starting when enabled

**Check**:
1. Global switch: `homelab.services.enable = true`
2. Host switch: `homelab.services.hosts.<hostname>.enable = true`
3. Individual service: `nixosSetup.services.<service>.enable = true`

All three must be `true` for a service to run.

### Issue: Hostname mismatch

**Error**: Services don't respond to host-specific settings

**Fix**:
```nix
# Make sure these match:
networking.hostName = "Bellamy";  # In host config
homelab.services.hosts.bellamy.enable = true;  # Note: lowercase in Nix

# OR use consistent casing:
networking.hostName = "bellamy";
homelab.services.hosts.bellamy.enable = true;
```

## Next Steps

1. **Document your setup** - Keep a list of which hosts have services enabled
2. **Create runbooks** - Document your maintenance procedures
3. **Set up monitoring** - Track when services are disabled/enabled
4. **Automate deployments** - Use CI/CD to manage service states

## Example Full Integration

Here's a complete example showing all pieces together:

```nix
# flake.nix or shared config
{
  inputs = { ... };
  
  outputs = { ... }: {
    nixosConfigurations = {
      bellamy = nixpkgs.lib.nixosSystem {
        modules = [
          ./modules/base  # Imports base/services automatically
          ./hosts/bellamy
          {
            # Shared homelab config
            homelab = {
              enable = true;
              services = {
                enable = true;
                hosts = {
                  bellamy = {
                    enable = true;
                    description = "Production server";
                  };
                };
              };
            };
          }
        ];
      };
    };
  };
}

# hosts/bellamy/default.nix
{
  networking.hostName = "Bellamy";
  
  nixosSetup.services = {
    traefik.enable = true;
    memos.enable = true;
    # Services automatically controlled by base layer
  };
}
```

Deploy:
```bash
sudo nixos-rebuild switch --flake .#bellamy
```

Done! Your services are now managed by the base layer.
