---
id: HML-014
title: Investigate and fix GitHub runner disk space issue
status: In Progress
assignee: []
created_date: '2026-08-08 20:49'
updated_date: '2026-08-09 09:42'
labels: []
dependencies: []
priority: high
type: bug
ordinal: 15000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
GitHub Actions runner is failing with "No space left on device" error during action download phase. The runner is hosted on the github-runner VM (Ubuntu 22.04 LTS on Proxmox).

**Error context:**
- Failure occurs when downloading action repositories (webfactory/ssh-agent@v0.9.0, actions/checkout@main, DeterminateSystems/nix-installer-action@main)
- Error message: "No space left on device"

**Access:**
- Host: github-runner (Ubuntu 22.04 LTS, kernel 6.17.4-2-pve)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Identify which disk/partition is full and current space usage breakdown
- [x] #2 Determine root cause (logs, cache, build artifacts, Docker images, etc.)
- [x] #3 Clean up unnecessary files to free immediate space
- [x] #4 Implement long-term solution (automated cleanup, disk expansion, volume management)
- [x] #5 Verify GitHub Actions runner can successfully download actions and complete workflow runs
- [x] #6 Document cleanup procedure and prevention strategy
- [ ] #7 Set up systemd timer or cron job for periodic Nix garbage collection (nix-collect-garbage --delete-older-than Xd)
- [ ] #8 Configure systemd journal retention policy (SystemMaxUse and/or MaxRetentionSec in journald.conf)
- [ ] #9 Test automation runs successfully
- [ ] #10 Verify disk usage remains stable over time (check after 1-2 weeks)
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
**Root cause:** Systemd journal logs accumulated to 3.2G over time

**Investigation:**
- Disk was 100% full (93G/98G used, only 5.5M available)
- Runner cache was only 706M (not the issue)
- Journal logs were 3.2G

**Fix applied:**
- Ran `journalctl --vacuum-time=7d` to delete journals older than 7 days
- Freed 2.9G of disk space
- Final state: 79G/98G used (85%), 15G available

**Long-term solution needed:** AC #4 still open - need automated log rotation/cleanup policy

**Final cleanup results:**
- Nix garbage collection (--delete-older-than 7d) completed
- Total space freed: 88GB
- Final disk usage: 4.9G/98G (6% used, 88G available)
- Runner has plenty of headroom now
<!-- SECTION:NOTES:END -->
