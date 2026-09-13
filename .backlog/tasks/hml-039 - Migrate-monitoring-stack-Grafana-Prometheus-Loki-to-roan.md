---
id: HML-039
title: Migrate monitoring stack (Grafana/Prometheus/Loki) to roan
status: To Do
assignee: []
created_date: '2026-09-12 23:46'
labels:
  - homelab
  - monitoring
  - migration
dependencies: []
priority: high
type: task
ordinal: 45000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Move monitoring stack currently enabled on nixos workstation to roan LXC (192.168.0.103 / 100.99.235.113) so workstation no longer hosts observability. Module bundles Grafana+Prometheus+Loki in modules/nixos/services/monitoring/grafana/default.nix. Track all phases here and update as changes land.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Monitoring stack runs on roan and is reachable via expected vHost/ports
- [ ] #2 nixos workstation no longer runs Grafana/Prometheus/Loki
- [ ] #3 Dashboards and history preserved or explicitly re-created
<!-- AC:END -->
