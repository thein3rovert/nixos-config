---
id: doc-001
title: Home-Manager Configuration Architecture
type: guide
created_date: '2026-08-14 12:21'
updated_date: '2026-08-14 13:01'
tags:
  - nixos
  - home-manager
  - configuration
  - flake
---
# Home-Manager Configuration Architecture

## Overview

This document explains how the home-manager configuration is structured in this NixOS flake, covering the two modes of operation, how inheritance works, and common pitfalls (like infinite recursion).

---

## Two Modes of Home-Manager

### 1. NixOS Integration Mode
**Used for**: NixOS systems where home-manager is part of the system configuration (e.g. `marcus`, `finn`, etc.)

**Structure**:
```nix
# hosts/marcus/home.nix
{ self, ... }: {
  home-manager.users.thein3rovert = self.homeManagerModules.thein3rovert;
}
```

**Key characteristics**:
- Wraps config in `home-manager.users.<username>`
- `home-manager` namespace exists because home-manager is loaded as a NixOS module
- Activated with `nixos-rebuild switch`
- `pkgs` is provided eagerly by the NixOS system

---

### 2. Standalone Mode
**Used for**: Non-NixOS systems (Ubuntu, macOS, other distros) — e.g. `trikru` (Ubuntu server)

**Structure**:
```nix
# homes/thein3rovert/trikru.nix
{ pkgs, lib, ... }: {
  home.packages = [ pkgs.vim ];  # Direct, no wrapper
  programs.zsh.enable = true;
}
```

**Key characteristics**:
- Direct module format — **NO** `home-manager.users.<name>` wrapper
- Activated with `home-manager switch --flake .#thein3rovert@trikru`
- `pkgs` is provided lazily through `_module.args` (this matters — see recursion section)

### ⚠️ Common Mistake

```nix
# ❌ WRONG in standalone mode
{ self, ... }: {
  home-manager.users.thein3rovert = self.homeManagerModules.thein3rovert;
}
```

The `home-manager.users.<name>` option only exists when home-manager is imported as a NixOS module. In standalone mode there is no `home-manager` namespace — you ARE home-manager.

**Analogy**:
- NixOS integration = "Hey NixOS, install home-manager for user X with this config"
- Standalone = "I AM home-manager, here's my config directly"

---

## File Structure

```
nixos-config/
├── modules/
│   ├── flake/
│   │   └── home-manager.nix          # Defines flake outputs
│   └── home/
│       ├── default.nix                # Imports custom modules
│       ├── thein3rovert/              # User-specific modules (homeSetup.*)
│       └── programs/                  # Program-specific modules
│
└── homes/
    └── thein3rovert/
        ├── default.nix                # Base config (shared by all systems)
        └── trikru.nix                 # Host-specific overrides (Ubuntu server)
```

---

## What Each File Does

### `modules/flake/home-manager.nix`
Defines the flake outputs for home-manager:

```nix
{
  flake = {
    # Module exports for reuse (imported by NixOS hosts AND standalone configs)
    homeManagerModules = {
      thein3rovert = ../../homes/thein3rovert;  # → loads default.nix
      default = ../home;                         # → custom modules (homeSetup.*)
    };

    # Standalone configurations for non-NixOS systems
    homeConfigurations."thein3rovert@trikru" = mkStandalone {
      host = "trikru";
      # modules loaded in order:
      modules = [
        self.homeManagerModules.thein3rovert    # Base config
        ../../homes/thein3rovert/${host}.nix    # Host overrides
      ];
    };
  };
}
```

### `homes/thein3rovert/default.nix`
Base configuration shared by all systems. **See the "Infinite Recursion" section below for the correct structure.**

### `homes/thein3rovert/trikru.nix`
Host-specific overrides — minimal, just what differs from base.

---

## The Import Chain

When you run `home-manager switch --flake .#thein3rovert@trikru`:

```
1. Flake loads: modules/flake/home-manager.nix
   └─ Finds: homeConfigurations."thein3rovert@trikru"

2. mkStandalone loads modules in order:
   ├─ self.homeManagerModules.thein3rovert
   │   └─ = homes/thein3rovert/default.nix
   │       └─ imports: self.homeManagerModules.default
   │           └─ = modules/home/default.nix (custom modules)
   │
   └─ homes/thein3rovert/trikru.nix (host overrides)

3. Result: Merged config with base + custom modules + host overrides
```

---

## ⚠️ Infinite Recursion Pitfall (IMPORTANT)

### What Happened
Setting `home.stateVersion` inside a `mkIf pkgs.stdenv.isLinux` block caused infinite recursion in **standalone** mode but not NixOS integration mode.

### Why It Broke Standalone But Not NixOS

| Mode | How `pkgs` is provided |
|------|------------------------|
| NixOS integration | Eagerly, before user config evaluates |
| Standalone | Lazily via `_module.args.pkgs` |

The recursion chain in standalone:
```
1. Home-manager runs assertions (needs home.stateVersion)
2. stateVersion is inside `mkIf pkgs.stdenv.isLinux { ... }`
3. Evaluating mkIf → needs pkgs
4. pkgs → needs _module.args
5. _module.args → needs config
6. config → needs stateVersion... 💥 LOOP
```

### The Rule
> **Options that home-manager needs during assertion checks (like `stateVersion`, `username`) MUST be set at the unconditional base level — never inside `mkIf` blocks that depend on `pkgs`.**

### ❌ Wrong Pattern
```nix
config = mkMerge [
  { home.username = "thein3rovert"; }
  (mkIf pkgs.stdenv.isLinux {
    home.stateVersion = "25.11";  # ← causes recursion in standalone
  })
];
```

### ✅ Right Pattern
```nix
config = mkMerge [
  {
    # Required options — always set at base
    home.stateVersion = "25.11";
    home.username = "thein3rovert";
  }
  (mkIf pkgs.stdenv.isLinux {
    # Only put things that actually differ per OS
    home.homeDirectory = "/home/thein3rovert";
    home.packages = [ pkgs.btop ];
  })
  (mkIf pkgs.stdenv.isDarwin {
    home.homeDirectory = "/Users/thein3rovert";
  })
];
```

### What Goes Where

| Attribute | Location | Reason |
|-----------|----------|--------|
| `home.stateVersion` | Base (unconditional) | Required by assertions |
| `home.username` | Base (unconditional) | Same on all systems |
| `home.homeDirectory` | `mkIf` per OS | Actually differs |
| Linux-only packages | `mkIf pkgs.stdenv.isLinux` | Platform-specific |
| Darwin-only aliases | `mkIf pkgs.stdenv.isDarwin` | Platform-specific |

---

## When to Use Which Pattern

### Scenario 1: Adding a New Non-NixOS Host (e.g. new Ubuntu box)
1. Create `homes/thein3rovert/<hostname>.nix` with host-specific settings only
2. Add to `modules/flake/home-manager.nix`:
   ```nix
   homeConfigurations."thein3rovert@<hostname>" = mkStandalone { host = "<hostname>"; };
   ```

### Scenario 2: Adding a New NixOS Host
1. Add to `hosts/<hostname>/home.nix`:
   ```nix
   { self, ... }: {
     home-manager.users.thein3rovert = self.homeManagerModules.thein3rovert;
   }
   ```

### Scenario 3: Changing Shared Settings
Edit `homes/thein3rovert/default.nix` — affects all systems.

### Scenario 4: Adding Custom Modules
Add to `modules/home/thein3rovert/` or `modules/home/programs/` — auto-available via `default.nix`.

---

## Overriding Values in Host Configs

Use `lib.mkForce` when overriding options set at base:

```nix
# trikru.nix
{ pkgs, lib, ... }: {
  home.stateVersion = lib.mkForce "25.05";  # Override default 25.11
  home.packages = with pkgs; [ vim ];        # Adds to base packages
  programs.zsh.enable = true;
}
```

**Merge behavior**:
- Lists (`packages`): concatenated automatically
- Attribute sets: merged recursively
- Scalars (`stateVersion`): conflict → use `mkForce` to override

---

## Testing Your Config

```bash
# Check flake syntax (catches recursion errors)
nix flake check

# Build without activating (dry-run)
nix build .#homeConfigurations."thein3rovert@trikru".activationPackage

# Apply configuration (Ubuntu/standalone)
home-manager switch --flake .#thein3rovert@trikru

# Apply configuration (NixOS host)
sudo nixos-rebuild switch --flake .#marcus
```

---

## Summary Cheat Sheet

| Question | Answer |
|----------|--------|
| Ubuntu server config? | Standalone mode, no `home-manager.users` wrapper |
| NixOS host config? | Use `home-manager.users.<name> = self.homeManagerModules.<name>` |
| Infinite recursion on `home.stateVersion`? | Move it OUT of `mkIf` to the base block |
| Override a base value? | Use `lib.mkForce` |
| Where do custom modules live? | `modules/home/` — auto-loaded via `self.homeManagerModules.default` |
| Where does base user config live? | `homes/thein3rovert/default.nix` |
| Where do host-specific configs live? | `homes/thein3rovert/<hostname>.nix` |
