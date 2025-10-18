## Server Profile

NixOS profile optimized for headless server environments.

## Usage

```
{
myNixOS.profiles.server.enable = true;
}
```

## What It Does

    Minimal footprint: Disables documentation and reduces system overhead.
    Log management: Volatile journald storage with 32MB limits to preserve disk space.
    File monitoring: Optimized inotify limits for server workloads.
    Memory management: ZRAM swap with zstd compression for efficiency.
    Security: Automatic fail2ban protection against brute force attacks.
    Performance tuning: BPF-based automatic kernel tuning.
    Reliability: systemd-oomd for out-of-memory protection.

    Key Changes for 2GB RAM + Minimal Logging:

    Disabled bpftune - Saves 10-20MB RAM and CPU cycles
    Reduced journal to 8MB - Keeps last 3 days only (plenty for minimal logging)
    Disabled enableUserSlices in oomd - Saves monitoring overhead
    Set zram to 25% - Gives you ~512MB compressed swap without eating too much RAM

## Important Notes

    Disables coredumps and emergency mode for unattended operation.
