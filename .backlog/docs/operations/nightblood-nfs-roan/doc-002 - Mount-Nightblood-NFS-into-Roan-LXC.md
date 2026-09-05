---
id: doc-002
title: Mount Nightblood NFS into Roan LXC
type: guide
created_date: '2026-09-05 10:29'
updated_date: '2026-09-05 10:34'
tags:
  - nfs
  - proxmox
  - lxc
  - roan
  - nightblood
---
# Mount Nightblood NFS into Roan LXC

## Why this is required

Roan (CT 103) is an unprivileged Proxmox LXC. Although `features: mount=nfs` relaxes LXC policy, the container's user namespace cannot mount `rpc_pipefs` or NFS reliably. The safe design is:

1. Mount Nightblood's NFS export on the Proxmox host `mount-weather`.
2. Bind-mount the host path into Roan.
3. Do not enable the NFS client profile inside Roan.

## Where the data is actually stored

There is only **one copy** of the data: it is physically stored on Nightblood's 100GB data disk. The two `/mnt/nightblood` paths are only access points to that same remote data:

- `/mnt/nightblood` on `mount-weather` is an NFS window into Nightblood.
- `/mnt/nightblood` inside Roan is a bind-mounted window into the host's NFS window.

Writing a 10GB file from Roan consumes approximately 10GB on Nightblood only; it does not consume another 10GB on the Proxmox host or Roan. If the NFS mount is unavailable, do not write into the plain host mount directory, because that could place data on the Proxmox host instead.

## Environment

- Proxmox host: `mount-weather` (`192.168.0.20`)
- LXC: Roan (`CT 103`)
- NFS server: Nightblood (`192.168.0.105` LAN; `100.77.212.11` Tailscale)
- Export: `/srv/nfs`
- Proxmox mount: `/mnt/nightblood`
- Roan mount: `/mnt/nightblood`

Use Nightblood's LAN address from `mount-weather` unless Tailscale is installed and connected on the Proxmox host. The NFS export must permit the selected source network.

## Procedure

Run on `mount-weather` as root:

```bash
apt update
apt install -y nfs-common
mkdir -p /mnt/nightblood
mount -t nfs4 192.168.0.105:/srv/nfs /mnt/nightblood
mountpoint /mnt/nightblood
```

Add a persistent host mount to `/etc/fstab`:

```fstab
192.168.0.105:/srv/nfs /mnt/nightblood nfs4 _netdev,nofail,x-systemd.automount,x-systemd.requires=network-online.target 0 0
```

Reload and test:

```bash
systemctl daemon-reload
mount -a
ls /mnt/nightblood
```

Attach it to Roan:

```bash
pct set 103 -mp0 /mnt/nightblood,mp=/mnt/nightblood
pct reboot 103
pct exec 103 -- mountpoint /mnt/nightblood
pct exec 103 -- ls -la /mnt/nightblood
```

If `mp0` is already occupied, use the next free slot (`mp1`, `mp2`, etc.). Proxmox bind-mount changes generally require a container restart.

## Roan NixOS configuration

Leave `nixosSetup.profiles.nfs.isClient` disabled on Roan. The path is supplied by Proxmox and should not appear as a NixOS NFS filesystem, avoiding failures of `var-lib-nfs-rpc_pipefs.mount` and `remote-fs.target` during deployment.

## Troubleshooting

```bash
# On Nightblood
exportfs -v
systemctl status nfs-server

# On mount-weather
mountpoint /mnt/nightblood
systemctl status mnt-nightblood.automount mnt-nightblood.mount
journalctl -u mnt-nightblood.mount
pct config 103

# Inside Roan
mountpoint /mnt/nightblood
findmnt /mnt/nightblood
```

- `access denied by server`: update Nightblood's export allowlist and run `exportfs -ra`.
- `No route to host`: verify the chosen Nightblood address is reachable from `mount-weather`.
- Empty/stale path in Roan: verify the host NFS mount first, then restart CT 103.
- Ownership appears numeric: account for unprivileged LXC UID/GID mapping when setting permissions on Nightblood.
