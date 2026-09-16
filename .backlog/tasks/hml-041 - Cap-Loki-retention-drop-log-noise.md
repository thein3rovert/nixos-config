---
id: HML-041
title: Cap Loki retention + drop log noise
status: Done
assignee: []
created_date: '2026-09-13 01:41'
updated_date: '2026-09-13 01:52'
labels:
  - homelab
  - monitoring
dependencies: []
priority: high
type: task
ordinal: 56000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Loki burns ~400M/day with no retention cap on roan's 20G disk. Cap at 14 days and drop info-level noise (kestra scheduler ticks, podman chatter, session scopes) in Vector while keeping warnings and errors.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Loki keeps 14 days via compactor retention
- [x] #2 Info-level spam from kestra/podman units dropped, warnings kept
- [x] #3 Daily ingest visibly reduced, dashboard/logs verified working
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Loki module: compactor retention_enabled + limits_config.retention_period 336h (14d). 2. Vector normalize: abort session scopes; abort priority>4 (info/debug) for podman-kestra.service + podman.service. 3. Validate VRL with local vector binary BEFORE deploy (lesson from HML-040.03). 4. Deploy 4 hosts, verify streams + volume drop + dashboard.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented: Loki compactor retention 336h + Vector drops (session scopes, info/debug for kestra+podman units). VRL validated with store binary (fixed raw-string regex escaping). Eval OK incl retention_period. NEEDS deploy x4, then verify volume drop + dashboard.

Loki needed delete_request_store=filesystem alongside retention_enabled (build-time validation caught it, roan untouched). Added. Retry deploy.

VRL E630: string() is fallible, needs ?? form. Fixed (local validate only catches syntax, strict checks run on host - noted). Redeploy x4.

Final verify: vector active x4, kestra+podman.service 0 lines/5m (was ~1100), Loki ready + compactor ACTIVE, grafana 200, disk 8.7G/20G steady. Loki error lines are deploy-restart noise only.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Disk safe: Loki compactor retention 336h active, Vector drops kestra/podman info spam + session scopes (top spammers went from ~90% of 1.6M lines/day to zero in 5m window), Grafana 200, disk steady at 47%.
<!-- SECTION:FINAL_SUMMARY:END -->
