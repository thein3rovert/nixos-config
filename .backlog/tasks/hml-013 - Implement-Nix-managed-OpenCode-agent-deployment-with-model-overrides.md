---
id: HML-013
title: Implement Nix-managed OpenCode agent deployment with model overrides
status: Done
assignee: []
created_date: '2026-08-08 16:59'
updated_date: '2026-08-15 20:15'
labels: []
dependencies: []
priority: high
type: feature
ordinal: 18000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build a Nix-based deployment system for OpenCode agents using canonical TOML format with per-host model override capability.

## Context
- Polis repo contains agents currently in markdown format (`.md` with YAML frontmatter)
- Need to support two deployment models:
  1. Workstations: Manual git clone to ~/.config/opencode (no changes)
  2. NixOS servers: Nix-managed via home-manager with model overrides
- Want to match m3ta's canonical agent format using TOML

## Goals
- Convert agents from markdown → canonical TOML format
- Build lib with loadAgents (using builtins.fromTOML)
- Use existing renderForOpencode lib
- Enable per-server model overrides via NixOS config

## Architecture
```
polis/agents/<agent-name>/
  ├── agent.toml         # Canonical metadata
  └── system-prompt.md   # System prompt content
```

## References
- m3ta's AGENTS repo: https://code.m3ta.dev/m3tam3re/AGENTS
- OpenCode docs: https://opencode.ai/docs/agents
- Local lib: ~/nixos-config/lib/agents/
<!-- SECTION:DESCRIPTION:END -->
