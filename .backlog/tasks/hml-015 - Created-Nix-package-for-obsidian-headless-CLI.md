---
id: HML-015
title: Created Nix package for obsidian-headless CLI
status: Done
assignee: []
created_date: '2026-08-15 15:06'
updated_date: '2026-08-15 15:15'
labels: []
dependencies: []
type: feature
ordinal: 17000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Created a Nix package derivation for obsidian-headless (Obsidian Sync/Publish CLI tool) and added it to the nixos-config pkgs overlay.

**What we built:**
- Package: obsidian-headless v0.0.14
- Location: `pkgs/obsidian-headless/default.nix`
- Binary: `ob` command
- Added to: `homes/thein3rovert/trikru.nix`

**Approaches tried:**
1. ❌ fetchurl from npm registry + stdenv.mkDerivation (simple wrapper) - Dependencies not included in tarball
2. ❌ buildNpmPackage with fetchFromGitHub - No package-lock.json, only pnpm-lock.yaml
3. ❌ Fetching pnpm-lock.yaml separately with postPatch - buildNpmPackage still required npm lock file
4. ❌ buildNpmPackage with pnpmDeps - Still tried to fetch npm deps internally
5. ✅ **stdenv.mkDerivation + fetchPnpmDeps + pnpmConfigHook** - Success!

**What failed and why:**
- Simple wrapper approach: npm tarball doesn't include node_modules (got "Cannot find module 'commander'" error)
- buildNpmPackage approaches: Tool expects npm lock files, not pnpm
- fetcherVersion issues: Needed `fetcherVersion = 4` (not "v9", not 3)

**What worked:**
```nix
stdenv.mkDerivation + {
  fetchPnpmDeps with fetcherVersion = 4
  pnpm in nativeBuildInputs
  pnpmConfigHook
  nodejs_22
  makeBinaryWrapper
}
```

**Key files modified:**
- Created `pkgs/obsidian-headless/default.nix`
- Updated `pkgs/default.nix` (added obsidian-headless entry)
- Updated `homes/thein3rovert/trikru.nix` (added to home.packages)

**How to update this package in the future:**

1. Check for new version at https://github.com/obsidianmd/obsidian-headless/tags
2. Update version in default.nix
3. Set src.hash to empty (all A's), build to get correct hash
4. Set pnpmDeps.hash to empty, build to get correct hash
5. Test: `./result/bin/ob --help` and `./result/bin/ob --version`
6. Commit and deploy

Important: Uses pnpm (not npm), requires fetchPnpmDeps with fetcherVersion = 4
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Package builds successfully with nix-build
- [x] #2 Binary ob works and shows help
- [x] #3 Package available through overlay in pkgs
- [x] #4 Added to trikru host configuration
- [x] #5 Git tracked (no not tracked by Git errors)
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Detailed Update Process

**Step-by-step guide for updating obsidian-headless:**

```bash
# 1. Check latest version
curl -s https://api.github.com/repos/obsidianmd/obsidian-headless/tags | jq -r '.[0].name'
# Or: npm info obsidian-headless version

# 2. Edit the package file
cd /home/thein3rovert/nixos-config/pkgs/obsidian-headless
vim default.nix  # Update version = "X.X.X"

# 3. Clear src hash (change to all A's)
# In default.nix, line ~21: hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

# 4. Build to get new src hash
cd /home/thein3rovert/nixos-config
NIXPKGS_ALLOW_UNFREE=1 nix-build -E 'with import <nixpkgs> { config.allowUnfree = true; }; callPackage ./pkgs/obsidian-headless {}' 2>&1 | grep -A 1 "hash mismatch"
# Copy the "got: sha256-XXX" value

# 5. Update src hash in default.nix with the value from step 4

# 6. Clear pnpmDeps hash (change to all A's)
# In default.nix, line ~26: hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

# 7. Build again to get pnpmDeps hash
NIXPKGS_ALLOW_UNFREE=1 nix-build -E 'with import <nixpkgs> { config.allowUnfree = true; }; callPackage ./pkgs/obsidian-headless {}' 2>&1 | grep -A 1 "hash mismatch"
# Copy the "got: sha256-XXX" value

# 8. Update pnpmDeps hash in default.nix

# 9. Final build and test
NIXPKGS_ALLOW_UNFREE=1 nix-build -E 'with import <nixpkgs> { config.allowUnfree = true; }; callPackage ./pkgs/obsidian-headless {}'
./result/bin/ob --version  # Should show new version
./result/bin/ob --help     # Should work without errors

# 10. Clean up and commit
rm result
git add pkgs/obsidian-headless/default.nix
git commit -m "pkgs/obsidian-headless: X.X.X -> Y.Y.Y"
git push

# 11. Deploy to host
home-manager switch --flake .#thein3rovert@trikru
```

**Troubleshooting:**
- If build fails with "Cannot find module": Check that pnpm/pnpmConfigHook are in nativeBuildInputs
- If fetcherVersion error: Must be 3 or 4 (we use 4 for pnpm lockfile v9)
- If 404 on GitHub source: Version tag might not exist, check tags page first

## Why This Approach Works - Technical Explanation

**Understanding the Problem:**

Node.js packages can use different package managers:
- **npm** - Uses `package-lock.json` or `npm-shrinkwrap.json`
- **yarn** - Uses `yarn.lock`
- **pnpm** - Uses `pnpm-lock.yaml`

Obsidian-headless uses **pnpm**, which has a different dependency resolution and storage model than npm.

**Why buildNpmPackage Failed:**

`buildNpmPackage` is designed specifically for npm packages. It:
1. Expects `package-lock.json` or `npm-shrinkwrap.json`
2. Uses `npm install` under the hood
3. Sets `npmDepsHash` which fetches dependencies via npm's install process
4. Cannot work with pnpm lock files

When we tried it, even with pnpmDeps set, buildNpmPackage still tried to run npm internally and failed because there was no npm lock file.

**Why Our Solution Works:**

```nix
stdenv.mkDerivation + fetchPnpmDeps + pnpmConfigHook
```

**1. stdenv.mkDerivation:**
- Lower-level builder that gives us full control
- Doesn't assume any specific build system
- We can manually orchestrate the build process

**2. fetchPnpmDeps:**
- Specifically designed to fetch pnpm dependencies
- Reads `pnpm-lock.yaml` from the source
- Downloads all dependencies to a fixed-output derivation
- `fetcherVersion = 4` tells it which pnpm lockfile version to parse (v9 lockfiles need fetcher version 4)
- Returns a derivation containing all node_modules

**3. pnpmConfigHook:**
- Runs during the configure phase
- Sets up pnpm environment variables
- Links the fetched dependencies (from fetchPnpmDeps) into node_modules
- Configures pnpm to use the Nix store for packages
- Runs `pnpm install --offline --frozen-lockfile` to install dependencies without network access

**4. pnpm in nativeBuildInputs:**
- Provides the actual `pnpm` binary needed by pnpmConfigHook
- Without this, you get "pnpm binary not found" error

**5. makeBinaryWrapper:**
- Creates a wrapper script for the CLI
- Points Node.js to the installed package location
- Makes the `ob` command available in PATH

**The Build Flow:**

```
1. unpackPhase: Extract source from GitHub
2. patchPhase: (automatic)
3. configurePhase: pnpmConfigHook runs
   → Links fetchPnpmDeps output to node_modules
   → Runs pnpm install --offline
4. buildPhase: Skipped (dontBuild = true)
5. installPhase: Our custom install
   → Copy everything to $out/lib/node_modules/obsidian-headless
   → Create wrapper script at $out/bin/ob
```

**Key Insights for Future Packages:**

**Use buildNpmPackage when:**
- Package uses npm (has package-lock.json)
- Standard npm build process works
- No special build requirements

**Use stdenv.mkDerivation + fetchPnpmDeps when:**
- Package uses pnpm (has pnpm-lock.yaml)
- You need custom build/install steps
- buildNpmPackage doesn't work

**Use stdenv.mkDerivation + fetchYarnDeps when:**
- Package uses yarn (has yarn.lock)
- Similar pattern to pnpm

**For other Node packages, check:**
1. What lock file exists? (package-lock.json vs pnpm-lock.yaml vs yarn.lock)
2. Does it need native compilation? (Add python3, gcc, etc.)
3. What's the main entry point? (Look at package.json "bin" field)
4. Are dependencies included in npm tarball? (Usually not, need to fetch separately)

**Why fetcherVersion = 4:**

Pnpm lockfile versions:
- v3.x lockfiles → fetcherVersion = 3
- v4.x-v9.x lockfiles → fetcherVersion = 4

Our package has `lockfileVersion: '9.0'` in pnpm-lock.yaml, so we use fetcherVersion = 4.

**Why python3 is needed:**

The `better-sqlite3` dependency is a native Node module that needs to be compiled. Native modules require:
- python3 (for node-gyp)
- gcc (usually available in stdenv)
- Build tools for the specific platform

Without python3, you'd get errors during the pnpm install phase when it tries to build native modules.

## Systemd Service for Continuous Sync

Created a systemd user service module to run `ob sync --continuous` automatically.

**Location:** `modules/nixos/profiles/systemd/obsidian-sync/default.nix`

**Features:**
- Runs as user service (not root)
- Auto-starts on boot
- Auto-restarts on failure (30s delay)
- Waits for network to be online
- Security hardened (PrivateTmp, NoNewPrivileges, ProtectSystem)
- Configurable vault path

**Setup Process:**

1. **First-time vault setup (required before enabling service):**
```bash
# Login to Obsidian account
ob login

# Navigate to your vault
cd ~/Documents/my-vault

# Setup sync for this vault
ob sync-setup --vault "My Vault Name"

# Test manual sync works
ob sync
```

2. **Enable service in host config:**
```nix
# In homes/thein3rovert/trikru.nix (or your host config)
nixosSetup.profiles.systemd.obsidian-sync = {
  enable = true;
  vaultPath = "%h/Documents/my-vault";  # %h = home directory
  user = "thein3rovert";
};
```

3. **Deploy:**
```bash
home-manager switch --flake .#thein3rovert@trikru
```

4. **Service Management:**
```bash
# Check status
systemctl --user status obsidian-sync

# View logs (live)
journalctl --user -u obsidian-sync -f

# Start/stop/restart
systemctl --user start obsidian-sync
systemctl --user stop obsidian-sync
systemctl --user restart obsidian-sync

# Enable/disable auto-start
systemctl --user enable obsidian-sync
systemctl --user disable obsidian-sync
```

**Configuration Options:**

```nix
nixosSetup.profiles.systemd.obsidian-sync = {
  enable = true;              # Enable the service
  vaultPath = "%h/vault";     # Path to vault (%h = home dir)
  user = "thein3rovert";      # User to run as
};
```

**Troubleshooting:**

- **Service fails immediately:** Check vault is setup with `ob sync-status` in vault directory
- **Permission denied:** Ensure user has read/write access to vault path
- **Network errors:** Service waits for network, but check connectivity
- **Sync conflicts:** Check logs with `journalctl --user -u obsidian-sync -f`

**Files modified:**
- Created `modules/nixos/profiles/systemd/obsidian-sync/default.nix`
- Updated `modules/nixos/profiles/systemd/default.nix` (added import)
- Updated `homes/thein3rovert/trikru.nix` (enabled service with example config)
<!-- SECTION:NOTES:END -->
