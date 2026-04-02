# FileBrowser Service

Simple file browser for accessing files over LAN.

## Configuration

Enable in your NixOS config:
```nix
nixosSetup.services.fileshare.enable = true;
```

## How It Works

This service uses two components:

1. **Systemd Service** (`setup-filebrowser-config`) - Located at `modules/nixos/profiles/systemd/filebrowser/`
   - Runs before the container starts
   - Reads the agenix secret at runtime
   - Generates `/var/lib/filebrowser/data/config.yaml` with the decrypted password
   - Ensures directories exist with proper permissions

2. **Podman Container** (`podman-fileshare`)
   - Runs the FileBrowser web interface
   - Mounts the config file and data directories
   - Accessible on port 8900

The systemd service dependency chain: `agenix.service` → `setup-filebrowser-config.service` → `podman-fileshare.service`

## Access

- URL: `http://localhost:8900`
- Username: Configured in systemd service
- Password: Stored in agenix secret at `config.age.secrets.fileshare.path`

## Data Storage

All data persists across rebuilds:
- `/var/lib/filebrowser/data/database.db` - User accounts, settings, permissions
- `/var/lib/filebrowser/data/config.yaml` - Config file (auto-generated from secret)
- `/var/lib/filebrowser/files/` - Your browsable files

## Verification

Check the setup service:
```bash
systemctl status setup-filebrowser-config
cat /var/lib/filebrowser/data/config.yaml
```

Check the container:
```bash
systemctl status podman-fileshare
```
