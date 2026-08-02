---
id: HML-009
title: >-
  Investigate and fix issue with kestra always failing when postgres not
  avalable
status: In Progress
assignee: []
created_date: '2026-08-02 10:09'
updated_date: '2026-08-02 19:30'
labels: []
dependencies: []
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Each time my postgres instance on my other server goes down my kestra always fails, am i am sure its because it cant find and connect to progres which make sense but when it comes back it..instead of just connecting automatically..it wont it will just remain in the failed state and that is not cool..i dont want that so i neede to find a way to fix it
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add systemd restart policy to podman-kestra service
- [x] #2 Configure RestartSec delay between restart attempts
- [ ] #3 Test Kestra auto-recovery when Postgres goes down and comes back up
- [ ] #4 Verify Kestra reconnects automatically without manual intervention
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Problem Analysis

Kestra container connects to PostgreSQL on remote server (emily via Tailscale). When Postgres goes down:
1. Kestra fails immediately 
2. When Postgres comes back, Kestra remains in failed state
3. No automatic recovery/reconnection

## Root Cause

The `podman-kestra.service` has no restart policy configured. NixOS `virtualisation.oci-containers` doesn't add restart behavior by default.

## Solution

Add systemd service override to `modules/nixos/profiles/systemd/kestra/default.nix`:

```nix
systemd.services."podman-kestra" = {
  serviceConfig = {
    Restart = "on-failure";
    RestartSec = "30s";
    StartLimitIntervalSec = "300";
    StartLimitBurst = "5";
  };
};
```

This will:
- Restart Kestra automatically when it fails
- Wait 30s between restart attempts
- Allow up to 5 restarts in 5 minutes before giving up
- Auto-recover when Postgres comes back online

## Implementation Complete ✅

Added restart policy to `/modules/nixos/profiles/systemd/kestra/default.nix` (lines 71-80).

**Next Steps:**
1. Deploy to marcus: `sudo nixos-rebuild switch` or via CI
2. Test by stopping Postgres on emily
3. Verify Kestra auto-restarts when Postgres comes back
4. Check logs: `journalctl -u podman-kestra -f`
<!-- SECTION:NOTES:END -->
