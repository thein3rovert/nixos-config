---
id: doc-003
title: Nightblood NFS and Zerobyte Backup Flow
type: guide
created_date: '2026-09-09 18:00'
tags:
  - nfs
  - nightblood
  - zerobyte
  - backup
  - architecture
  - proxmox
---
# Nightblood NFS and Zerobyte Backup Flow

## Purpose

Document how files move from source hosts through Nightblood NFS to Zerobyte on roan, including the special ownership model caused by roan being an unprivileged Proxmox LXC.

Related work: HML-031, HML-032, HML-033, HML-034, HML-035, HML-037, and playbooks task PLB-006.

## Architecture

```mermaid
flowchart LR
    subgraph SourceHosts[Source hosts]
        NIXOS[nixos host<br/>uid 1000<br/>NFS client]
        OTHER[Other physical or VM hosts<br/>optional NFS clients]
        ROANDATA[roan local files<br/>container uid 1000]
    end

    subgraph Nightblood[Nightblood - dedicated NFS server]
        DISK[/dev/sdb]
        EXPORT[/srv/nfs]
        SOURCES[/srv/nfs/sources]
        DISK --> EXPORT --> SOURCES
        NC[nixos-config]
        VAULT[thein3rovert_vault]
        GARAGE[garage]
        ROANTEST[roan-test / future roan sources]
        SOURCES --> NC
        SOURCES --> VAULT
        SOURCES --> GARAGE
        SOURCES --> ROANTEST
    end

    subgraph Proxmox[Proxmox host]
        HOSTMOUNT[NFS mount<br/>192.168.0.105:/srv/nfs]
    end

    subgraph Roan[roan - unprivileged LXC]
        PASSTHROUGH[/mnt/nightblood<br/>host bind-mount passthrough]
        ZERO[Zerobyte container]
    end

    subgraph Repositories[Backup repositories]
        R2[Cloudflare R2<br/>cloudflare-main-backup]
        GARAGEREPO[Garage S3 restic repo<br/>s3personal]
    end

    NIXOS -->|Ansible sync-sources / rsync| SOURCES
    OTHER -->|Optional per-host sync_sources_map| SOURCES
    ROANDATA -->|Ansible sync-sources| ROANTEST
    EXPORT -->|NFS mounted by Proxmox host| HOSTMOUNT
    HOSTMOUNT -->|Mount propagated into LXC| PASSTHROUGH
    PASSTHROUGH -->|Read-only container volumes| ZERO
    ZERO -->|Restic backups and mirrors| R2
    ZERO -->|Restic repository| GARAGEREPO
```

## Components

### Nightblood

- Dedicated Ubuntu NFS server
- Tailscale IP: `100.77.212.11`
- LAN IP: `192.168.0.105`
- Data device: `/dev/sdb`
- Export root: `/srv/nfs`
- Backup staging root: `/srv/nfs/sources`
- Managed by the Ansible `nfs-server` role

The Ansible-managed export is stored at `/etc/exports.d/storage.exports` and currently permits the Tailscale CGNAT range:

```text
/srv/nfs 100.64.0.0/10(rw,sync,no_subtree_check,root_squash)
```

A legacy LAN export may still exist in `/etc/exports`:

```text
/srv/nfs 192.168.0.0/24(rw,sync,no_subtree_check,root_squash)
```

The effective export table is checked with:

```bash
sudo exportfs -v
```

### nixos host

- Bare-metal NFS client
- Mounts Nightblood directly through Tailscale:

```text
100.77.212.11:/srv/nfs -> /mnt/nightblood
```

- User `thein3rovert` is uid `1000`, gid `100`
- Runs the Ansible `sync-sources` operation for:
  - `/home/thein3rovert/nixos-config`
  - `/home/thein3rovert/Documents/project/thein3rovert_vault`
  - `/var/storage/garage`

These are mirrored to:

```text
/mnt/nightblood/sources/nixos-config
/mnt/nightblood/sources/thein3rovert_vault
/mnt/nightblood/sources/garage
```

### roan

- Unprivileged Proxmox LXC
- Runs Zerobyte and Dockhand
- **Is not an NFS client inside the container**
- Proxmox mounts the Nightblood export and passes the mount into roan at `/mnt/nightblood`

Evidence:

```text
/mnt/nightblood source: 192.168.0.105:/srv/nfs
propagation: shared,slave
```

Do not enable the NixOS NFS client profile inside roan. LXC blocks the `sunrpc` and `autofs` mounts used by rpcbind and systemd automounts, causing failed activation.

## Unprivileged LXC UID mapping

Roan uses this UID/GID map:

```text
container uid 0 -> Proxmox host uid 100000 (range 65536)
container gid 0 -> Proxmox host gid 100000 (range 65536)
```

Therefore:

| Identity inside roan | Identity seen by Proxmox/NFS |
| --- | --- |
| uid `1000` | uid `101000` |
| gid `100` | gid `100100` |

Files owned by Nightblood uid `1000` are outside roan's mapped host range and appear inside roan as `65534:65534` (`nobody:nogroup`). This is expected for an unprivileged LXC mount passthrough; it is not an NFSv4 idmap-domain failure.

### Ownership rules for staging directories

- Directories written by the nixos host: owner `1000:100` on Nightblood
- Directories written by roan: owner `101000:100100` on Nightblood
- Read-only Zerobyte source directories may display as `65534:65534` in roan but remain readable when permissions permit

Example for a roan-writable staging directory:

```bash
# Run on Nightblood
sudo mkdir -p /srv/nfs/sources/roan-test
sudo chown 101000:100100 /srv/nfs/sources/roan-test
```

Roan then sees that directory as `1000:100` and can write normally.

## Source synchronization

The Ansible project provides:

```text
roles/backup/sync-sources/
playbooks/sync-sources.yml
```

Each host declares its sources in:

```text
inventory/host_vars/<host>.yml
```

Example:

```yaml
sync_sources_map:
  roan-test:
    src: /home/thein3rovert/sync-test
```

The role:

1. Confirms `/mnt/nightblood` is mounted
2. Confirms each source exists and is non-empty
3. Runs `rsync -a --delete --itemize-changes`
4. Mirrors each source to `/mnt/nightblood/sources/<source-name>/`

Because `--delete` is used, the role refuses to run against missing or empty sources. Zerobyte/restic provides historical snapshots; staging is only the current mirror.

## Execution

Normal execution is orchestrated by Kestra. The justfile provides equivalent operator commands:

```bash
# Any declared host
just sync roan production

# Local validation on the nixos machine
just sync-local

# Guard/check-mode validation
just sync-dry nixos_host localhost
```

`sync-local` is a test convenience. Production orchestration should use the standard SSH-based playbook execution.

## Zerobyte flow

Zerobyte runs on roan and reads Nightblood staging through read-only container bind mounts. Existing examples:

```text
/mnt/nightblood/sources/nixos-config -> /nixos-config:ro
/mnt/nightblood/sources/thein3rovert_vault -> /thein3rovert_vault:ro
```

The Garage source should follow the same model:

```text
/mnt/nightblood/sources/garage -> /garage:ro
```

Zerobyte then performs restic backups to:

- Cloudflare R2 repository: `cloudflare-main-backup`
- Garage S3 restic repository: `s3personal` where applicable

## Troubleshooting

### Roan sees ownership as 65534

Expected when the Nightblood file owner is outside roan's unprivileged UID map. For roan-writable directories, use `101000:100100` on Nightblood.

### Roan cannot write to a staging directory

Check from Nightblood:

```bash
ls -lan /srv/nfs/sources
```

For a roan-owned source:

```bash
sudo chown 101000:100100 /srv/nfs/sources/<name>
```

### NFS activation fails inside roan

Do not configure NFS in the container. Errors involving these units indicate the wrong architecture:

```text
var-lib-nfs-rpc_pipefs.mount
rpc-gssd.service
auth-rpcgss-module.service
mnt-nightblood.automount
```

The mount belongs on the Proxmox host and is propagated into roan.

### Verify current flow

```bash
# On roan
findmnt -o TARGET,SOURCE,FSTYPE,PROPAGATION /mnt/nightblood
cat /proc/self/uid_map
cat /proc/self/gid_map

# On Nightblood
sudo exportfs -v
ls -lan /srv/nfs/sources

# From the Ansible project
just sync roan production
```

## Source-of-truth files

- `hosts/nixos/configuration.nix`
- `hosts/roan/configuration.nix`
- `modules/nixos/profiles/nfs/default.nix`
- Ansible `inventory/host_vars/nightblood.yml`
- Ansible `inventory/host_vars/nixos_host.yml`
- Ansible `inventory/host_vars/roan.yml`
- Ansible `roles/backup/sync-sources/`
- Ansible `playbooks/sync-sources.yml`
