# NFS Profile

Configures NFS client and/or server functionality.

## Usage

### Server (export shares)

```nix
nixosSetup.profiles.nfs.isServer = true;
nixosSetup.profiles.nfs.exports = ''
  /backups 10.10.10.12(rw,sync,no_subtree_check)
  /backups 100.0.0.0/8(rw,sync,no_subtree_check)
'';
```

### Client (mount remote shares)

```nix
nixosSetup.profiles.nfs.isClient = true;
nixosSetup.profiles.nfs.mounts = [
  {
    mountPoint = "/mnt/backups";
    device = "100.105.187.63:/backups";
    readOnly = false;  # optional, defaults to false
  }
  {
    mountPoint = "/mnt/garage";
    device = "100.105.187.63:/var/storage/garage";
    readOnly = true;
  }
];
```

### Both (server and client)

```nix
nixosSetup.profiles.nfs = {
  isServer = true;
  isClient = true;
  exports = ''...'';
  mounts = [ ... ];
};
```

## Options

| Option | Type | Description |
|--------|------|-------------|
| `isServer` | bool | Enable NFS server (export shares) |
| `isClient` | bool | Enable NFS client (mount remote shares) |
| `exports` | lines | NFS exports file contents |
| `mounts` | list | Remote NFS mounts to configure |

## Default Mount Options

- `vers=4`
- `x-systemd.automount`
- `noauto`
- `ro` (when `readOnly = true`)
