---
id: HML-034
title: Configure Nightblood NFS service
status: To Do
assignee: []
created_date: '2026-09-04 19:27'
labels:
  - ansible
  - nfs
  - tailscale
  - storage
dependencies: []
modified_files:
  - roles/nfs-server/tasks/main.yml
  - roles/nfs-server/defaults/main.yml
  - inventory/production.yml
  - inventory/host_vars/nightblood.yml
  - site.yml
priority: high
type: feature
ordinal: 38000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure the Ubuntu Nightblood VM as the local NFS server using a reusable Ansible role so roan and the workstation can consume shared storage over Tailscale.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Nightblood formats and persistently mounts its dedicated data disk at /srv/nfs
- [ ] #2 Nightblood exports /srv/nfs to approved Tailscale clients
- [ ] #3 The NFS server is enabled and active
- [ ] #4 The role is reusable for future NFS server hosts
- [ ] #5 Ansible syntax and runtime checks pass
<!-- AC:END -->
