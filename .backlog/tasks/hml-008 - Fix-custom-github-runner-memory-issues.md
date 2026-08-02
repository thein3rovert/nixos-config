---
id: HML-008
title: Fix custom github runner memory issues
status: Done
assignee: []
created_date: '2026-08-02 09:23'
updated_date: '2026-08-02 11:36'
labels:
  - ci
  - nix
  - proxmox
  - memory
  - github-runner
dependencies: []
priority: medium
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
My custom github runner for building my nix config runs out of memory during a large build but i need to investigare whyor at least how i can fix it, i dont just want to increase the memory for the sake of it, i want to see what i can squeez out of it and before scaling, maybe even investigate building a custom binary cache on my main sever (emily) and point it to the custom github runner to use during build
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Runner has swap enabled to prevent OOM hangs
- [x] #2 Container swap allocation is functional
- [x] #3 Monitor 4GB RAM + 1GB swap performance under load
- [ ] #4 Investigate binary cache on emily server for offload
- [x] #5 Decide on RAM/swap bump based on real usage data
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Investigate current memory usage on runner (LXC 120)
2. Check host swap availability
3. Enable swap on Proxmox host if missing
4. Verify container inherits swap
5. Monitor performance with current 4GB RAM + 1GB swap
6. Investigate binary cache on emily to offload builds
7. Decide on scaling only if real data shows need
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Investigation

### Initial state
- LXC 120 on Proxmox (192.168.0.50) hung during nix build
- Container config: 4GB RAM, 1024MB swap allocated
- Container was frozen — `pct exec` couldn't connect
- `nix build` process observed at 2.3GB memory usage during eval alone
- Combined with GitHub runner + nix-daemon + systemd = 4GB exhausted

### Root cause of hang
**Proxmox host had no active swap** — despite a 7.6GB `pve-swap` LV existing.

Even though container config specifies `swap: 1024`, LXC swap requires the host to have swap. Host had:
- Swap LV `/dev/pve/swap` (7.6GB) — properly formatted with UUID
- Not activated (`swapon` empty)
- Missing from `/etc/fstab`

Result: container saw `SwapTotal: 0` and OOM-froze when Nix eval spiked.

## Fix Applied

### Host-level (Proxmox 192.168.0.50)
```bash
swapon /dev/pve/swap
echo 'UUID=7485eb80-1eed-4318-891d-39a1ae8cdf6d none swap sw 0 0' >> /etc/fstab
```

### Verification
- Host swap: 7.6GB active ✅
- Container swap: 1GB active ✅ (previously 0)
- Runner recovered after `pct stop 120 --skiplock && pct start 120`

## Current Configuration (Post-Fix)

**LXC 120 (github-runner):**
- 2 CPU cores
- 4GB RAM
- 1GB swap (now functional)
- 100GB disk on LVM_MAIN

**Proxmox host:**
- 23GB RAM total, 9GB free typical
- 7.6GB swap enabled and persisted

## Decision: Watch Before Scaling

User chose to monitor current setup (4GB RAM + 1GB swap) before bumping resources. Rationale:
- Get real data on memory pressure with swap available
- Avoid overprovisioning
- Cheaper to bump swap than RAM

**Escalation path if hangs recur:**
1. First: bump swap to 2GB
2. Then: bump RAM to 8GB
3. Then: investigate binary cache on emily server to offload build work

## Follow-up (Not Yet Done)

1. **Binary cache on emily** — Would dramatically reduce runner memory pressure since most builds would just be substitutions from cache
2. **Serialize build jobs** — Currently nixos/marcus/bellamy could theoretically run in parallel (~7GB combined). Concurrency already prevents this via workflow, but worth confirming.
3. **Nix evaluation caching** — Consider `--eval-cache` options if evals are the main memory sink

## Real-World Memory Data (During Build - 2026-08-02 09:51 UTC)

Build in progress: nixos configuration

```
               total        used        free      shared  buff/cache   available
Mem:           4.0Gi       3.2Gi        32Mi        39Mi       749Mi       742Mi
Swap:          1.0Gi       1.0Gi       0.0Ki
```

**Analysis:**
- RAM utilization: 3.2GB / 4.0GB (80%)
- Swap utilization: 1.0GB / 1.0GB (100% MAXED OUT ⚠️)
- Total working set: ~4.2GB

**Top memory consumers:**
1. nix-daemon: 1.7GB (42%)
2. nix build: 1.3GB (33%)
3. bun build tool: 287MB (7%)
4. cachix daemon: 77MB
5. Runner.Worker: 66MB

**Verdict:**
Build is surviving thanks to swap, but running at absolute capacity. Swap maxed at 100% means any spike could still trigger OOM. The 1GB swap buffer is insufficient for these builds.

**Next Action:**
Bump swap to 2GB via Terraform to provide adequate headroom. Data confirms this is necessary, not over-provisioning.

## Validation Results (2026-08-02 09:54 UTC)

**nixos build completed successfully** — the heaviest build passed without hanging! ✅

Memory after nixos completion:
```
               total        used        free      shared  buff/cache   available
Mem:           4.0Gi       181Mi       2.5Gi        44Mi       1.4Gi       3.8Gi
Swap:          1.0Gi        34Mi       989Mi
```

**Key findings:**
- Swap fix prevented OOM hang during peak build (previously would have frozen)
- Memory dropped from 4.2GB working set (80% RAM + 100% swap) to ~215MB after build
- marcus and bellamy builds in progress — much lighter footprint
- Swap usage dropped from 100% maxed to 3.4%

**Conclusion:**
Fix is **validated** — CI builds now complete successfully with 1GB swap buffer. However, since swap hit 100% during peak nixos build, upgrading to 2GB swap provides safety margin for future builds or concurrent operations.

**User decision:** Proceed with 2GB swap upgrade via Terraform as planned, despite successful builds. This is a prudent safety measure, not emergency response.
<!-- SECTION:NOTES:END -->
