---
id: HML-015
title: Created Nix package for obsidian-headless CLI
status: Done
assignee: []
created_date: '2026-08-15 15:06'
updated_date: '2026-08-15 20:14'
labels:
  - nix
  - obsidian
dependencies: []
priority: medium
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

## Systemd Service for Continuous Sync (Home-Manager)

Created a systemd user service module for standalone home-manager configs to run `ob sync --continuous` automatically.

**Location:** `modules/home/systemd/ob-sync/default.nix`

**Features:**
- Runs as user service (not root)
- Auto-starts on boot
- Auto-restarts on failure (30s delay)
- Waits for network to be online
- Security hardened (PrivateTmp, NoNewPrivileges, ProtectSystem)
- Configurable vault path
- Service named `ob-sync` (not `obsidian-sync`)

**Setup Process:**

1. **First-time vault setup (required before enabling service):**
```bash
# Login to Obsidian account
ob login

# Navigate to your vault
cd /root/vault  # Or wherever your vault is

# Setup sync for this vault
ob sync-setup --vault "My Vault Name"

# Test manual sync works
ob sync
```

2. **Disable old system service if it exists:**
```bash
# Stop and disable the old root-level service
sudo systemctl stop obsidian-sync
sudo systemctl disable obsidian-sync
sudo rm /etc/systemd/system/obsidian-sync.service
sudo systemctl daemon-reload
```

3. **Enable service in home-manager config:**
```nix
# In homes/thein3rovert/trikru.nix (or your host config)
homeSetup.systemd.ob-sync = {
  enable = true;
  vaultPath = "/root/vault";  # Your vault path
};
```

4. **Deploy:**
```bash
home-manager switch --flake .#thein3rovert@trikru
```

5. **Service Management:**
```bash
# Check status
systemctl --user status ob-sync

# View logs (live)
journalctl --user -u ob-sync -f

# Start/stop/restart
systemctl --user start ob-sync
systemctl --user stop ob-sync
systemctl --user restart ob-sync

# Enable/disable auto-start
systemctl --user enable ob-sync
systemctl --user disable ob-sync
```

**Configuration Options:**

```nix
homeSetup.systemd.ob-sync = {
  enable = true;                    # Enable the service
  vaultPath = "/root/vault";        # Path to vault (can use %h for home dir)
};
```

**Differences from old system service:**

| Aspect | Old System Service | New User Service |
|--------|-------------------|------------------|
| Service name | `obsidian-sync` | `ob-sync` |
| Location | `/etc/systemd/system/` | User systemd |
| Runs as | root | thein3rovert |
| Binary path | `/usr/bin/ob` | Nix store path |
| Management | `systemctl` | `systemctl --user` |
| Config | Manual file | Declarative Nix |

**Troubleshooting:**

- **Service fails immediately:** Check vault is setup with `ob sync-status` in vault directory
- **Permission denied:** Ensure user has read/write access to vault path
- **Network errors:** Service waits for network, but check connectivity
- **Sync conflicts:** Check logs with `journalctl --user -u ob-sync -f`
- **Old service still running:** Stop the old root service first (see step 2 above)

**Files modified:**
- Created `modules/home/systemd/ob-sync/default.nix` (home-manager user service)
- Created `modules/home/systemd/default.nix` (import)
- Updated `modules/home/default.nix` (added systemd import)
- Updated `homes/thein3rovert/trikru.nix` (enabled service with /root/vault path)

## Fix: better-sqlite3 Native Module Build (Post-Deployment Issue)

**Problem discovered after deploy:**

The `ob-sync` systemd service kept failing with:
```
Error: Could not locate the bindings file. Tried:
 → .../better-sqlite3/build/Release/better_sqlite3.node
 ...
```

**Root cause:**
- User thought `ob sync` worked manually on trikru, but they were testing with `/usr/bin/ob` (v0.0.13, npm-installed with prebuilt binaries)
- Our Nix package (v0.0.14) was missing the `better_sqlite3.node` native module
- `pnpmConfigHook` runs `pnpm install --offline --frozen-lockfile` which SKIPS postinstall scripts (that would normally build native modules)
- Native modules like `better-sqlite3` need C++ compilation via node-gyp

**Attempted fixes that didn't work:**
1. `pnpm rebuild better-sqlite3` - Silently did nothing (pnpm blocks scripts by default)
2. `dontBuild = true` + relying on prebuilt binaries - Not included in package

**Working fix - Manual native module build:**

```nix
buildPhase = ''
  runHook preBuild
  
  export npm_config_build_from_source=true
  export npm_config_nodedir=${nodejs_22}
  
  echo "Building better-sqlite3 native module..."
  pushd node_modules/.pnpm/better-sqlite3@12.11.1/node_modules/better-sqlite3
  ${nodejs_22}/bin/npm run build-release
  popd
  
  runHook postBuild
'';
```

**Key insights:**

1. **`pnpm install --offline` skips build scripts** - This is a safety feature but prevents native module compilation
2. **`npm run build-release`** - The `better-sqlite3` package has a `build-release` script that runs `node-gyp` with correct flags
3. **Environment variables needed:**
   - `npm_config_build_from_source=true` - Force compilation, not download
   - `npm_config_nodedir=${nodejs_22}` - Point to correct Node.js headers

**Verification after fix:**

```bash
# On trikru, systemd service now works:
systemctl --user status ob-sync
# ● ob-sync.service - Obsidian Headless Continuous Sync
#      Active: active (running) since Sat 2026-08-15 15:39:09 UTC
#      Main PID: 15244 (node)

# Logs show successful sync every 30 seconds:
journalctl --user -u ob-sync -f
# Aug 15 15:40:41 trikru ob[15244]: Fully synced
# Aug 15 15:41:11 trikru ob[15244]: Fully synced
# Aug 15 15:41:41 trikru ob[15244]: Fully synced
```

**Lessons learned for future Node.js packages with native modules:**

1. **Always test with the actual Nix-built binary** - Don't trust that `command works` if it might be resolving to a different install
2. **pnpm/npm offline installs skip postinstall scripts** - Native modules WILL be missing
3. **Check for `.node` files** after building:
   ```bash
   find result -name '*.node' 2>/dev/null
   ```
4. **Common native modules that need this treatment:**
   - `better-sqlite3`
   - `node-sqlite3` 
   - `bcrypt`
   - `sharp`
   - Any package with C/C++ source and node-gyp

**Final systemd service (simple and working):**

```nix
systemd.user.services.ob-sync = {
  Unit = {
    Description = "Obsidian Headless Continuous Sync";
    After = [ "network-online.target" ];
    Wants = [ "network-online.target" ];
  };
  Service = {
    Type = "simple";
    WorkingDirectory = cfg.vaultPath;
    ExecStart = "${pkgs.obsidian-headless}/bin/ob sync --continuous";
    Restart = "always";
    RestartSec = 10;
    TimeoutStopSec = 5;
    KillMode = "mixed";
    KillSignal = "SIGTERM";
  };
  Install = {
    WantedBy = [ "default.target" ];
  };
};
```

**Status: ✅ VERIFIED WORKING on trikru** (as of 2026-08-15 15:45 UTC)
<!-- SECTION:NOTES:END -->

## Comments

<!-- COMMENTS:BEGIN -->
author: assistant
created: 2026-08-15 15:53
---
## Bonus: opencode-web Home-Manager Systemd Service

Also created a home-manager systemd module for opencode-web (replacing the old root-level system service on trikru).

**Files:**
- Created: `modules/home/systemd/opencode-web/default.nix`
- Updated: `modules/home/systemd/default.nix` (added import)
- Updated: `homes/thein3rovert/trikru.nix` (enabled with port 3000)

**Configuration:**
```nix
homeSetup.systemd.opencode-web = {
  enable = true;
  port = 3000;         # or null to use opencode default
  hostname = "0.0.0.0";
};
```

**Key gotchas learned:**
1. **`pkgs.opencode` doesn't duplicate** - it references the same store path as `homeSetup.programs.opencode`. Nix store is content-addressed, no double install.
2. **`xdg-open` required** - opencode web tries to open browser on startup. Must add `pkgs.xdg-utils` to PATH env in the service, otherwise service logs errors (even though it still runs).
3. **Port option nullable** - Used `types.nullOr types.int` with `lib.optionalString` in ExecStart to allow using opencode's built-in default when port is null.

**Cleanup performed on trikru:**
- Stopped/disabled/removed `/etc/systemd/system/obsidian-sync.service` (was running as root with npm ob)
- Stopped/disabled/removed `/etc/systemd/system/opencode-web.service` (was running as root)
- Uninstalled npm global `obsidian-headless@0.0.13` (40 packages removed)
- `/usr/bin/ob` now gone, replaced by Nix-managed `/home/thein3rovert/.nix-profile/bin/ob`

**Verified working (2026-08-15 15:53 UTC):**
```
● opencode-web.service - Opencode Web Interface
     Active: active (running) since Sat 2026-08-15 15:52:08 UTC
     ExecStart: opencode web --hostname 0.0.0.0 --port 3000 --log-level WARN
     
Local access:    http://localhost:3000
Network access:  http://192.168.0.102:3000
Tailscale:       http://100.118.122.19:3000

Listening: 0.0.0.0:3000 ✅
```

**Both services now Nix-managed on trikru:**
- ✅ `ob-sync.service` (user) - continuous vault sync
- ✅ `opencode-web.service` (user) - web IDE on port 3000
---
<!-- COMMENTS:END -->
