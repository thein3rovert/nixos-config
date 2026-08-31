---
id: HML-023
title: Build custom Docker image for Kestra infrastructure execution environment
status: To Do
assignee: []
created_date: '2026-08-23 23:14'
labels:
  - docker
  - kestra
  - infrastructure
  - devops
dependencies: []
priority: medium
type: feature
ordinal: 27000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build a custom Docker image for Kestra execution environments to eliminate repeated tool installation across workflows.

**Current problem:**
- Every Kestra workflow install same tools (ansible, gcloud, openssh, python3, etc.)
- Adds 30-60 seconds per workflow run
- Prone to install failures (network, package changes)
- Duplicated install logic across workflows

**Solution:**
Build custom Docker image `ansible-infra:latest` with:
- ansible (base from willhallonline/ansible)
- gcloud SDK (for GCS operations)
- openssh-client
- python3 + py3-crcmod
- coreutils (GNU date)
- libc6-compat
- Any other common infra tools

**Benefits:**
- Faster workflow runs (skip install steps)
- More reliable (immutable image)
- Reusable across all infra workflows
- Version-pinned for reproducibility

**Reference:** HML-022.01 highlighted this need - workflow spent significant time installing gcloud SDK, coreutils, etc. Custom image would eliminate this.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Create Dockerfile with ansible + gcloud SDK + supporting tools pre-installed
- [ ] #2 Build image with common dependencies: openssh-client, python3, curl, bash, coreutils, py3-crcmod, libc6-compat
- [ ] #3 Push image to container registry (Forgejo/GHCR/Docker Hub)
- [ ] #4 Tag with version and latest
- [ ] #5 Update postgres-backup-gcs-sync workflow to use custom image
- [ ] #6 Remove redundant apk add / curl gcloud install steps from workflows
- [ ] #7 Document build/publish process in README
- [ ] #8 Set up automated image builds (CI/CD) for updates
- [ ] #9 Test workflows run faster with pre-baked image
<!-- AC:END -->
