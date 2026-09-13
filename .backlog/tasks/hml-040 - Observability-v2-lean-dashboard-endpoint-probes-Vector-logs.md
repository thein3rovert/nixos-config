---
id: HML-040
title: 'Observability v2 - lean dashboard, endpoint probes, Vector logs'
status: To Do
assignee: []
created_date: '2026-09-13 00:24'
labels:
  - homelab
  - monitoring
  - observability
dependencies: []
priority: medium
type: task
ordinal: 51000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Level up roan monitoring: rebuild the one bloated dashboard lean, add blackbox-style endpoint probing, and ship logs/metrics with Vector into Loki. Track design + implementation here.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Single lean dashboard provisioned as code replaces bloated one
- [ ] #2 Endpoint probes (vHosts/services) visible in Prometheus/Grafana
- [ ] #3 Host + container logs queryable in Loki/Grafana
<!-- AC:END -->
