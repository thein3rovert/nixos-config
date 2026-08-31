---
id: HML-018
title: Create Prometheus Ansible role for monitoring additional servers
status: Done
assignee:
  - '@thein3rovert'
created_date: '2026-08-22 10:40'
updated_date: '2026-08-22 11:48'
labels:
  - ansible
  - monitoring
  - prometheus
  - grafana
dependencies: []
type: feature
ordinal: 21000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a comprehensive Prometheus Ansible role to enable monitoring of Ubuntu servers in the homelab. Currently only monitoring 2 servers, need to expand monitoring to all servers via Grafana dashboard. Role should handle node exporter installation and configuration on Ubuntu hosts, plus future Prometheus components.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Role installs and configures prometheus-node-exporter on Ubuntu hosts
- [x] #2 Node exporter runs on port 9100 by default
- [x] #3 Role is added to site.yml with monitoring tag
- [x] #4 Role follows existing playbook structure (roles/prometheus/tasks/main.yml)
- [x] #5 Service starts automatically and persists across reboots
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create roles/prometheus/tasks/ directory structure
2. Create main.yml with tasks to:
   - Update apt cache
   - Install prometheus-node-exporter package
   - Enable and start prometheus-node-exporter service
   - Verify service is running on port 9100
3. Add Prometheus role to site.yml under 'Configure System' with monitoring tag
4. Follow existing role patterns (ansible.builtin modules, become: true, debug output)
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created roles/prometheus/tasks/main.yml with node exporter installation tasks following existing role patterns.

Added Prometheus role to site.yml with monitoring and prometheus tags after Kestra role.

Successfully deployed prometheus-node-exporter to Ubuntu servers only:
- becca (100.123.31.22)
- bellamy (100.105.187.63)
- github-runner (100.87.59.51)
- trikru (192.168.0.102)
- lincoln (100.87.231.18)
- raven (100.123.5.107)

Skipped NixOS hosts (finn, k3s-server, marcus) as they use the NixOS module at modules/nixos/services/monitoring/prometheusNode/default.nix instead.

All Ubuntu nodes now exposing metrics on port 9100 for Prometheus scraping.

Added play-level tags to site.yml (kubernetes, k8s for K8s deployments; k3s-inventory, k3s-monitoring, reports for K3S inventory) to keep monitoring role independent from k3s-inventory tasks.

Updated role to use port 3021 (matching NixOS module) instead of default 9100. Created systemd override.conf to configure --web.listen-address=:3021. All hosts now consistent on port 3021 for unified Prometheus scraping.

Added all 10 hosts to Prometheus scrapeConfigs in grafana/default.nix:
- NixOS hosts (4): marcus, finn, k3s-server, nixos
- Ubuntu hosts (6): becca, bellamy, github-runner, trikru, lincoln, raven

Added comprehensive comments explaining HTTP-over-Tailscale connectivity, hostname vs IP options, and how Prometheus polling works. NixOS config rebuilt and Prometheus now scraping all nodes on port 3021.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Created Prometheus Ansible role with node exporter installation for Ubuntu hosts. Role installs prometheus-node-exporter via apt, configures custom port 3021 (matching NixOS module) via systemd override, enables service for auto-start on boot, verifies port availability, and displays status. Added to site.yml with monitoring and prometheus tags. Follows existing role patterns (ansible.builtin modules, become: true, structured tasks). Added monitoring commands to justfile with production/dev/host-specific targets and dry-run variants. Successfully deployed to 6 Ubuntu servers: becca, bellamy, github-runner, trikru, lincoln, and raven. NixOS hosts (finn, k3s-server, marcus) use the existing NixOS module. Added play-level tags to site.yml to keep monitoring role independent from k3s-inventory tasks. Updated Prometheus scrapeConfigs in grafana/default.nix to include all 10 hosts (4 NixOS + 6 Ubuntu) on port 3021. Added comprehensive comments explaining HTTP-over-Tailscale connectivity. Verified working on becca (service active, port 3021 listening, 2.4MB memory usage). NixOS config rebuilt. All nodes now monitored in Grafana via Prometheus HTTP scraping every 10 seconds.
<!-- SECTION:FINAL_SUMMARY:END -->
