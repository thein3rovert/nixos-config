---
id: HML-025
title: Reduce Prometheus scrape frequency and duplicate target
status: Done
assignee:
  - AI
created_date: '2026-09-01 22:57'
updated_date: '2026-09-01 22:57'
labels:
  - nixos
  - prometheus
  - monitoring
dependencies: []
modified_files:
  - modules/nixos/services/monitoring/grafana/default.nix
priority: medium
type: enhancement
ordinal: 29000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Reduce unnecessary monitoring overhead while preserving host-level infrastructure metrics collected for Grafana dashboards and troubleshooting.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Prometheus scrapes node metrics once every 60 seconds
- [x] #2 Each monitored host appears only once in the node scrape targets
- [x] #3 The NixOS configuration evaluates successfully
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Change the global Prometheus scrape interval from 10 seconds to 60 seconds.
2. Remove the duplicate Bellamy node-exporter target while retaining all unique hosts.
3. Evaluate the NixOS host configuration and record the result.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Prometheus was scraping seven Node Exporter endpoints every 10 seconds and Bellamy appeared twice in the source configuration. Updated the interval to 60 seconds and removed the duplicate. Nix evaluation returned 60s and exactly one target per host.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Reduced Prometheus collection overhead by changing the global scrape interval from 10 seconds to 60 seconds and removing the duplicate Bellamy target. Verified through Nix evaluation that the resulting configuration uses a 60-second interval and contains seven unique node targets.
<!-- SECTION:FINAL_SUMMARY:END -->
