# Syncthing Setup Guide

## Overview

Syncthing is a decentralized file synchronization tool that allows you to sync files between devices without relying on a central server. It works over LAN, WAN, and VPN networks (like Tailscale).

## Key Concepts

### Device Identity
- Each Syncthing instance has a unique **Device ID** derived from its certificate
- Device IDs look like: `QSGQUHV-IGGMG2Z-FDLEO2H-XQQAPXD-K3LBXD6-5IQ2LCB-JUFALOV-QD7VEAN`
- To sync devices, you exchange Device IDs and add each other as devices

### Certificates and Keys
- Each device needs a certificate (`cert.pem`) and private key (`key.pem`)
- These are generated once with `syncthing generate --home=/tmp/st-certs`
- Store these securely (e.g., in agenix encrypted secrets)

### Folders
- A **Folder** is a directory that gets synced between devices
- Each folder has a **Folder ID** (unique identifier) and a **Folder Path** (local path)
- Folders can be shared with multiple devices (Send Only, Receive Only, or Send & Receive)

### Device Addressing
- `"dynamic"` - Uses local and global discovery to find device on any network
- `"tcp://ip:port"` - Direct connection to specific IP (good for local network)
- Over Tailscale, devices use `"dynamic"` and find each other via the VPN

## Server Setup (NixOS)

### 1. Generate Certificates

```bash
nix run nixpkgs#syncthing -- generate --home=/tmp/st-certs
```

This outputs:
- Certificate and key files in `/tmp/st-certs/`
- Your Device ID (e.g., `QSGQUHV-IGGMG2Z-...`)
- Certificate at: `cert.pem`
- Private key at: `key.pem`

### 2. Store Secrets

Add the cert and key files to your agenix secrets repository and reference them in your host configuration.

### 3. Configure Syncthing

In your host config, enable syncthing and configure:
- Enable the service with your user
- Point to cert/key files from agenix
- Set `guiAddress = "0.0.0.0:8384"` for LAN + Tailscale access
- Add devices and folders in the `settings` block

### 4. Rebuild and Create Sync Folder

```bash
sudo nixos-rebuild switch --flake .#hostname
mkdir -p ~/path/to/sync/folder
```

## Client Setup (WSL/Linux Laptop)

### 1. Install Syncthing

```bash
sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg

echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

sudo apt update && sudo apt install syncthing
```

### 2. Generate Device ID (First Time)

```bash
syncthing generate --home=/tmp/my-syncthing
# Note your Device ID from the output
```

### 3. Start Syncthing

```bash
# Run in background
nohup syncthing &

# Access GUI at http://localhost:8384
```

### 4. Configure via GUI

1. Open http://localhost:8384
2. Click **"Add Remote Device"**
3. Enter the server's Device ID
4. Give it a name (e.g., "nixos-server")
5. Optionally check "Introducer" to auto-receive shared folders
6. Save

### 5. Accept Shared Folders

When the server shares a folder:
1. You'll see a notification in the GUI
2. Click **"Add"** or **"Accept"**
3. Choose the folder path on your local machine
4. Optionally rename the folder label

### 6. Run as Background Service (Optional)

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/syncthing.service << 'EOF'
[Unit]
Description=Syncthing

[Service]
ExecStart=/usr/bin/syncthing serve --no-browser --no-restart --logflags=0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

systemctl --user enable syncthing.service
systemctl --user start syncthing.service
```

## Tailscale Integration

Syncthing works seamlessly over Tailscale because:
1. Both devices appear on the same VPN network (100.x.x.x)
2. Syncthing's "dynamic" addressing discovers devices globally
3. No port forwarding or NAT traversal needed

**Requirements:**
- Tailscale running on both devices
- Syncthing configured with `guiAddress = "0.0.0.0:8384"` on server
- Firewall port 8384 open on server

**Access remotely:**
- LAN: `http://<local-ip>:8384`
- Tailscale: `http://100.x.x.x:8384`

## Troubleshooting

### "Cannot connect to device"
- Ensure both devices are online
- Check Tailscale is running on both
- Verify device IDs are correct (no typos)
- Try using explicit IP: `addresses = [ "tcp://100.x.x.x:22000" ]`

### "Folder unshared"
- The device sharing the folder hasn't added your device ID
- Ask them to share the folder with you in their Syncthing GUI

### "Path doesn't exist"
- Create the folder manually: `mkdir -p ~/path/to/folder`
- Syncthing won't auto-create folders on the receiving end sometimes

### "Stuck scanning"
- Restart syncthing on both devices
- Check for file permission issues
- Ensure disk space is available

## Key Learnings

1. **Device IDs are tied to certificates** - If you regenerate certs, device ID changes and old connections break
2. **Folder IDs must match for same folder** - If you want to sync to an existing folder, use the same Folder ID
3. **First connection requires manual acceptance** - Both devices must accept each other
4. **Syncthing is bidirectional by default** - Both devices can send/receive unless configured otherwise
5. **No central server needed** - Devices connect directly (or via relays if NAT'd)
6. **Works great over VPN** - Tailscale makes it work seamlessly across the internet
7. **Remove and re-add folders to change path** - Can't edit folder path directly on receiving end