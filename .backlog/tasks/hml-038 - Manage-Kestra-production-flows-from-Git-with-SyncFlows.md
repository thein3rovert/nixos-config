---
id: HML-038
title: Manage Kestra production flows from Git with SyncFlows
status: In Progress
assignee:
  - thein3rovert
created_date: '2026-09-09 18:34'
updated_date: '2026-09-10 20:14'
labels:
  - kestra
  - gitops
  - automation
milestone: Homelab
dependencies: []
references:
  - 'https://kestra.io/docs/version-control-cicd/git'
  - kestra/production/
documentation:
  - 'https://kestra.io/docs/version-control-cicd/git'
modified_files:
  - kestra/production/git-sync-flows.yml
  - kestra/README.md
priority: high
type: feature
ordinal: 44000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Adopt Kestra GitOps for workflow deployment so files under `kestra/production/` in the nixos-config repository become the source of truth for the `ops` namespace. A bootstrap sync flow in Kestra should reconcile committed flow YAML into the instance, removing the need to manually import every workflow update.

This sync manages Kestra flow definitions only. Runtime workflows may still use `io.kestra.plugin.git.Clone` to fetch the separate playbooks repository when executing Ansible.

Start conservatively: Git is authoritative, missing flows are kept rather than deleted, and invalid syntax stops or safely reports the sync. Destructive reconciliation can be considered after the initial rollout is verified.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A bootstrap Kestra flow synchronizes workflow YAML from the configured Git repository and branch into the `ops` namespace
- [x] #2 Only files under the intended Kestra production directory are synchronized
- [ ] #3 Git is the source of truth and UI edits to managed flows are overwritten by the next synchronization
- [ ] #4 Missing Git flows are kept during the initial rollout to prevent accidental deletion
- [x] #5 Invalid flow YAML fails safely and surfaces a clear synchronization error
- [ ] #6 Repository credentials are stored in Kestra secrets or KV storage and are not committed to Git
- [ ] #7 Synchronization can run on a schedule and can also be triggered manually
- [ ] #8 The existing Ansible source-sync workflow appears in Kestra after Git synchronization
- [ ] #9 Runtime `git.Clone` tasks for fetching the playbooks repository continue to work independently
- [ ] #10 The Kestra GitOps workflow and operator procedure are documented
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
# Implementation Plan (as executed - final)

## Working SyncFlows configuration
- Repo: https://github.com/thein3rovert/nixos-config (public, no token/username)
- Branch: main, gitDirectory: kestra/production, targetNamespace: ops
- kestraUrl: http://localhost:8080 (8090 is the host-mapped port; inside the container Kestra listens on 8080)
- No webhook (Kestra is internal-only); use scheduled polling or manual runs
- kestra/production/ must contain flow YAML only - Markdown fails validation

## Fixes applied during rollout
1. Initial failure: SyncFlows called Kestra API at localhost:8090 (connection refused) - fixed with kestraUrl http://localhost:8080
2. Next failure: README-postgres-backup-setup.md in kestra/production/ parsed as a flow and failed validation - moved to kestra/docs/postgres-backup-setup.md via git mv
3. User confirms sync now succeeds

## Remaining
- Verify remaining ACs (source-of-truth overwrite behavior, missing-flow handling, schedule/manual runs, runtime Clone independence, docs) before Done
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-09-10 (working setup recorded): Public repo https://github.com/thein3rovert/nixos-config, branch main, gitDirectory kestra/production, targetNamespace ops, no auth. Fix 1: kestraUrl http://localhost:8080 (8090 is host-mapped; container listens on 8080) - resolved 'Connect to http://localhost:8090 failed: Connection refused'. Fix 2: moved kestra/production/README-postgres-backup-setup.md to kestra/docs/postgres-backup-setup.md via git mv - resolved 'Invalid flow imported from Git (README...): YAML parsing error'. Verified production/ is now YAML-only (5 flows). User confirms SyncFlows run now succeeds.

2026-09-10: Added kestra/production/failure-alert-discord.yml (Discord alert on any FAILED/WARNING execution via Flow trigger, DISCORD_WEBHOOK secret). Placed in the synced production dir with namespace ops to match the SyncFlows targetNamespace (sync rewrites namespaces to the target, so system namespace would not survive import). Next Git sync deploys it; justfile test-trigger recipe was considered and reverted per user request.
<!-- SECTION:NOTES:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: thein3rovert/opencode
created: 2026-09-09 21:45
---
Decision: use a GitHub webhook on pushes to the public nixos-config `main` branch instead of scheduled polling. Keep manual execution as a fallback. The Kestra webhook key must be stored securely and configured as the GitHub repository webhook secret/key; no Git repository credentials are required because the repository is public.
---
<!-- COMMENTS:END -->
