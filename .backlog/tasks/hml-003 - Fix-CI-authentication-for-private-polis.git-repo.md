---
id: HML-003
title: Fix CI authentication for private polis.git repo
status: Done
assignee: []
created_date: '2026-08-01 20:39'
updated_date: '2026-08-02 09:46'
labels:
  - ci
  - nix
  - github-actions
  - ssh
dependencies: []
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
GitHub Actions CI failing to fetch from ssh://git@github.com/thein3rovert/polis.git with error 'authentication required but no callback set'. Works locally but fails in CI environment. Started failing recently despite SSH key being configured via webfactory/ssh-agent. Blocks all CI builds (nixos, marcus, bellamy configurations).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 CI successfully fetches from polis.git repo
- [ ] #2 All three NixOS configurations build successfully in CI
- [ ] #3 Builds remain stable across multiple CI runs
- [ ] #4 No authentication errors in CI logs
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Identify root cause of CI SSH authentication failure
2. Verify deploy key is properly set up in GitHub and CI runner
3. Try environment variable fixes (GIT_SSH_COMMAND, NIX_SSHOPTS, SSH_AUTH_SOCK)
4. Try Nix config fixes (extra-sandbox-paths, sandbox=false, NIX_REMOTE)
5. Implement workaround: pre-clone polis with system git and override-input
6. Confirm all three configurations build successfully
7. Research long-term fix in Determinate Nix 3.0
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Root Cause

Determinate Nix 3.0 (released March 2025) changed the flake input fetching layer. The CI uses `DeterminateSystems/nix-installer-action@main` which silently pulled in Nix 3.0.

### Why it broke
- Nix uses **libgit2** internally for `git+ssh://` flake inputs
- libgit2 requires an explicit auth callback for SSH credentials
- Nix 3.0's fetching layer doesn't properly wire ssh-agent into libgit2
- The error 'authentication required but no callback set' is a libgit2-specific error

### Related upstream issues
- NixOS/nix#9133 - Fetching flake input with git+ssh requires the ssh executable (open since Oct 2023)
- Similar libgit2 issues in pygit2, libgit2sharp — confirms it's a libgit2 pattern
- No dedicated fix in DeterminateSystems/nix-src as of Nov 2025

## What Was Tried (In Order)

1. **GIT_SSH_COMMAND + SSH_AUTH_SOCK env vars** — Failed, Nix's libgit2 doesn't respect these
2. **NIX_SSHOPTS** — Failed, only affects `nix copy` not flake fetches
3. **extra-sandbox-paths for SSH_AUTH_SOCK** — Failed
4. **sandbox = false in NIX_CONFIG** — Failed, sandbox wasn't the issue
5. **NIX_REMOTE="" (bypass daemon)** — Failed
6. **git config --global url.insteadOf** — Failed (git not in PATH before Nix install; also doesn't help libgit2)
7. **Pre-clone with system git + --override-input** — WORKS ✅

## Working Solution

Pre-clone polis using system git (which uses ssh-agent properly), then override the flake input:

```yaml
- name: Pre-clone polis with SSH
  run: |
    nix profile add nixpkgs#git || true
    rm -rf /tmp/polis
    git clone git@github.com:thein3rovert/polis.git /tmp/polis

- name: Build
  env:
    GIT_SSH_COMMAND: "ssh -o StrictHostKeyChecking=accept-new"
    SSH_AUTH_SOCK: ${{ env.SSH_AUTH_SOCK }}
  run: nix build --override-input polis path:/tmp/polis ...
```

## Trade-offs

**Pros:**
- Works reliably
- Keeps SSH (no HTTPS/PAT needed)
- Uses system git which properly integrates with ssh-agent

**Cons:**
- Not best practice — bypasses Nix's native fetching
- `--override-input` breaks flake lock reproducibility (see 'not writing modified lock file' warning)
- Adds pre-clone step to each build job
- Adds `/tmp/polis` state management on self-hosted runners

## Related Bugs Found

- Marcus configuration has a JSON parse error in an opencode.json file (line 160) — user disabled opencode module on marcus as workaround

## Future Improvements (Not Yet Done)

1. **Pin nix-installer-action version** to prevent silent Nix upgrades breaking CI again
2. **Monitor Determinate Nix for libgit2 fix** — check quarterly
3. **Consider migrating to HTTPS + PAT** for cleaner flake fetching (would restore lock file integrity)
4. **Fix opencode.json** parse error on marcus separately
<!-- SECTION:NOTES:END -->
