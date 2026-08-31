---
id: HML-019
title: Customize Grafana Node Exporter dashboard for homelab needs
status: To Do
assignee: []
created_date: '2026-08-22 12:00'
labels:
  - grafana
  - monitoring
  - dashboard
dependencies: []
priority: low
type: enhancement
ordinal: 22000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The current Node Exporter Full dashboard (ID 1860) shows all available metrics but includes many panels not relevant for homelab monitoring. Create a streamlined custom dashboard focused on key metrics that matter: CPU usage, memory usage, disk space, network traffic, and system uptime. Remove or hide unnecessary panels to reduce visual clutter and improve dashboard load time.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Duplicate existing Node Exporter Full dashboard as starting point
- [ ] #2 Identify and remove unnecessary panels (keep CPU, memory, disk, network, uptime)
- [ ] #3 Organize remaining panels in logical sections
- [ ] #4 Dashboard loads faster with fewer panels
- [ ] #5 Save custom dashboard with descriptive name (e.g., 'Homelab Overview')
<!-- AC:END -->
