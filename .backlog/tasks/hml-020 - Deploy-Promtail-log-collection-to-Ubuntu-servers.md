---
id: HML-020
title: Deploy Promtail log collection to Ubuntu servers
status: To Do
assignee: []
created_date: '2026-08-22 12:18'
labels:
  - ansible
  - monitoring
  - loki
  - promtail
  - logging
dependencies: []
priority: medium
type: feature
ordinal: 23000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create Ansible role to install and configure Promtail on Ubuntu servers for centralized log collection. Currently only NixOS hosts send logs to Loki. Need to extend log collection to all Ubuntu servers (becca, bellamy, github-runner, trikru, lincoln, raven) to enable searching logs across entire homelab infrastructure via Grafana/Loki.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Create roles/promtail/tasks/main.yml following existing role patterns
- [ ] #2 Install Promtail on Ubuntu hosts via apt or binary download
- [ ] #3 Configure Promtail to scrape systemd journal logs
- [ ] #4 Set Loki URL to match NixOS config (http://loki.l.thein3rovert.com/loki/api/v1/push)
- [ ] #5 Add hostname labels for identifying log sources
- [ ] #6 Service starts automatically and persists across reboots
- [ ] #7 Add to site.yml with logging or monitoring tag
- [ ] #8 Verify logs appear in Grafana Explore from Ubuntu hosts
<!-- AC:END -->
