---
id: HML-040
title: 'Observability v2 - lean dashboard, endpoint probes, Vector logs'
status: Done
assignee: []
created_date: '2026-09-13 00:24'
updated_date: '2026-09-13 01:38'
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
- [x] #1 Single lean dashboard provisioned as code replaces bloated one
- [x] #2 Endpoint probes (vHosts/services) visible in Prometheus/Grafana
- [x] #3 Host + container logs queryable in Loki/Grafana
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Observability v2 complete: Homelab Overview dashboard as code (18 panels, old 4 removed), 15/15 blackbox probes, Vector logs from 4 hosts with 8 container streams. All verified live on roan.
<!-- SECTION:FINAL_SUMMARY:END -->
