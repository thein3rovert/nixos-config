---
id: HML-043
title: Fix k3s-server crash loop due to expired Tailscale auth
status: Done
assignee: []
created_date: '2026-09-21 18:53'
updated_date: '2026-09-21 18:56'
labels: []
dependencies: []
priority: high
type: bug
ordinal: 58000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
k3s-server is crash-looping because embedded etcd cannot bind to 100.85.190.19:2380. That Tailscale IP is missing since Tailscale is logged out. Need to restore Tailscale auth so k3s can start and API is reachable again.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tailscale is authenticated and 100.85.190.19 address is present on tailscale0
- [x] #2 k3s.service is active and stays running without crash-loop
- [x] #3 kubectl get pods succeeds against 127.0.0.1:6443
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Fixed via tailscale up CLI per user; playbook cannot auth this host due to different lab IP.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Re-authed Tailscale via `tailscale up` CLI on k3s-server, restoring 100.85.190.19 so etcd could bind and k3s API recovered. Playbook not usable here since server is on different lab IP.
<!-- SECTION:FINAL_SUMMARY:END -->
