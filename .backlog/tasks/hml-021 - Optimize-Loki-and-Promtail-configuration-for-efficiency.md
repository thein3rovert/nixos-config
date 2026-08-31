---
id: HML-021
title: Optimize Loki and Promtail configuration for efficiency
status: To Do
assignee: []
created_date: '2026-08-22 12:18'
labels:
  - loki
  - promtail
  - monitoring
  - performance
  - logging
dependencies: []
references:
  - 'https://grafana.com/docs/loki/latest/configure/'
priority: medium
type: enhancement
ordinal: 24000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Current Loki/Promtail configuration has several inefficiencies: stores data in /tmp (non-persistent), very high ingestion limits (50GB/s), no log retention policy, scrapes all logs including noisy debug/trace messages. Optimize configuration to reduce CPU/memory usage, implement proper retention, filter noisy logs, and use persistent storage for reliability.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Move Loki storage from /tmp to persistent location (/var/lib/loki)
- [ ] #2 Set reasonable retention period (e.g., 30 days)
- [ ] #3 Reduce ingestion rate limits from 50GB to practical values (10-20MB/s)
- [ ] #4 Add Promtail pipeline stages to drop debug/trace logs
- [ ] #5 Filter out noisy systemd units (NetworkManager, systemd-resolved, etc.)
- [ ] #6 Configure journald limits (SystemMaxUse=2G, MaxRetentionSec=7days)
- [ ] #7 Verify Loki CPU/memory usage is reasonable after changes
- [ ] #8 Test log queries still work in Grafana after optimization
<!-- AC:END -->
