---
id: HML-015
title: Set up automated cleanup for GitHub runner (Nix GC + journal rotation)
status: To Do
assignee: []
created_date: '2026-08-09 09:41'
updated_date: '2026-08-09 09:41'
labels: []
dependencies:
  - HML-014
priority: medium
type: task
ordinal: 16000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement automated maintenance to prevent disk space issues on the GitHub Actions runner.

**Context:**
- Recent incident: disk filled to 100% causing runner failures
- Manual cleanup freed 88GB (journal logs + old Nix generations)
- Need automation to prevent recurrence

**What needs automation:**
1. Nix garbage collection (remove generations older than 7-14 days)
2. Systemd journal rotation (keep last 7-14 days)

**Access:**
- Host: github-runner (Ubuntu 22.04 LTS)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Set up systemd timer or cron job for periodic Nix garbage collection (nix-collect-garbage --delete-older-than Xd)
- [ ] #2 Configure systemd journal retention policy (SystemMaxUse and/or MaxRetentionSec in journald.conf)
- [ ] #3 Test automation runs successfully
- [ ] #4 Document the automation setup and retention policies
- [ ] #5 Verify disk usage remains stable over time (check after 1-2 weeks)
<!-- AC:END -->
