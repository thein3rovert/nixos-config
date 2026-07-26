# `lib/agents.nix` — Agent Management Reference

This document explains every function in [`lib/agents.nix`](../lib/agents.nix).

## TL;DR — What this file does

`lib/agents.nix` is a **harness-agnostic agent management library**. It takes
**canonical agent definitions** (a single source of truth describing your AI
coding agents) and renders them into the file layouts expected by different
AI-coding tools: **OpenCode**, **Claude Code**, and **Pi**.

```
                            ┌─────────────────┐
   inputs.agents  ───────►  │  loadCanonical  │  ───► canonical attrset
   (flake input)            │                 │       (keyed by agent slug)
                            └─────────────────┘
                                      │
                       ┌───────────────┼───────────────┐
                       ▼               ▼               ▼
              renderForOpencode  renderForClaude   renderForPi
              (yaml+prompt)       (yaml+settings)  (AGENTS.md+SYSTEM.md)
                       │               │               │
                       └──────────┬────┴───────────────┘
                                  ▼
                          renderForTool  (dispatcher)
                                  │
                                  ▼
                        shellHookForTool (devShells)
```

The canonical format lives in your separate
[`AGENTS`](https://github.com/thein3rovert/AGENTS) flake. This Nix lib is the
**adapter layer** that turns one canonical description into many tool-specific
file layouts (so you can switch harnesses without rewriting your agents).

---

## File structure (top-level shape)

```nix
{ lib }:
let
  # ── Shared helpers ────────────────────
  parseRule = ...;            # internal — splits "pattern:action"
  renderAgentFiles = ...;     # internal — writes *.md files via linkFarm

  agentsLib = {
    # ── Public API ──────────────────────
    loadCanonical         = ...;
    renderForOpencode     = ...;
    renderForClaudeCode   = ...;
    renderForPi           = ...;
    renderForTool         = ...;   # dispatcher
    shellHookForTool      = ...;   # devShell convenience
  };
in
agentsLib
```

- The file takes only `{ lib }` (pure Nixpkgs lib) → can be imported anywhere.
- Returns `agentsLib` (an attrset of functions) — wired into your downstream
  lib under `m3taLib.agents.*` by your NixOS/home-manager config.
- Everything is **pure** — same inputs produce the same store paths, so these
  functions are safe inside derivations and `nix flake check`.

---

## Internal helpers

### `parseRule`

```nix
parseRule = ruleStr:
  { pattern, action };
```

**Purpose**: Split a permission rule string on the **last** colon to separate
the command pattern from its action (`allow` / `ask` / `deny`).

**Why split on the *last* colon**: Patterns themselves can contain colons
(e.g. URLs, paths). Splitting on the last one keeps the pattern intact:

| Input                       | pattern              | action  |
| --------------------------- | -------------------- | ------- |
| `"rm -rf *:ask"`            | `rm -rf *`           | `ask`   |
| `"/run/agenix/**:deny"`     | `/run/agenix/**`     | `deny`  |
| `"git push origin:allow"`   | `git push origin`    | `allow` |

**Implementation notes**:

- `lib.strings.splitString ":"` → list of parts.
- `lib.last parts` → the action (right of the final colon).
- `lib.init parts` → everything before; rejoined with `:` so patterns can
  contain colons.

Used by every renderer that processes per-pattern permission rules
(OpenCode + Claude Code; Pi has no per-pattern granularity).

---

### `renderAgentFiles`

```nix
renderAgentFiles = pkgs: canonical: mkContent: name: storePath;
```

**Purpose**: Shared primitive used by all three renderers. Takes the canonical
agent attrset and emits a directory of `<name>.md` files (one per agent).

**Arguments**:

| Arg        | Type           | Meaning                                                   |
| ---------- | -------------- | --------------------------------------------------------- |
| `pkgs`     | nixpkgs set    | Provides `linkFarm` and `writeText`.                       |
| `canonical`| attrset        | `loadCanonical` output — keyed by agent slug.             |
| `mkContent`| `name → agent → string` | Tool-specific formatter for one file.            |
| `name`     | string         | Name of the resulting derivation (cosmetic).              |

**Returns**: A **`linkFarm`** store path — a directory containing one
`<slug>.md` per agent, where each file's content is `mkContent slug agent`.

**Why a linkFarm**: It's a derivation that just symlinks to `writeText`
results. Cheap to build, idempotent, perfect for "drop a directory into
`~/.config/...`" patterns.

**Used by**:

- `renderForOpencode` (with mkFrontmatter-based content)
- `renderForClaudeCode` (with Claude-Code frontmatter)
- `renderForPi` (with pi-subagents frontmatter)

---

## Public API functions

### `loadCanonical`

```nix
loadCanonical = { agentsInput }: agentsInput.lib.loadAgents;
```

**Purpose**: Thin passthrough. Fetches the canonical agent attrset from the
`AGENTS` flake input (which exposes its own `lib.loadAgents`).

**Arguments**:

| Arg           | Type                | Meaning                                  |
| ------------- | ------------------- | ---------------------------------------- |
| `agentsInput` | flake input         | Your `inputs.agents` (the AGENTS repo).  |

**Returns**: An attrset keyed by agent slug, e.g.:

```nix
{
  chiron = {
    description = "Primary work agent";
    mode = "primary";
    systemPrompt = "...";
    permissions = { bash = { intent = "ask"; rules = [...]; }; ... };
    skills = [ "..." ];        # optional
    display_name = "Chiron";   # optional (used by Pi AGENTS.md rendering)
  };
  explore = { mode = "subagent"; ... };
  ...
}
```

**Why it's its own function (instead of inlining `agentsInput.lib.loadAgents`)**:
gives you a single place to point at the canonical source — easier to swap
repos, mock in tests, or extend with validation later.

---

### `renderForOpencode`

```nix
renderForOpencode = { pkgs, canonical, modelOverrides ? {} }: storePath;
```

**Purpose**: Produce a directory of `*.md` files for
[OpenCode](https://opencode.ai) consumption — placed at either:

- `~/.config/opencode/agents/` (system-level), or
- `.opencode/agents/` (project-level, via devShell shellHook).

**Output filename convention**: `<agent-slug>.md` — the basename (without
`.md`) becomes the agent name in OpenCode.

**Output file format**: YAML frontmatter followed by the agent's
`systemPrompt`:

```markdown
---
description: "Primary work agent."
mode: primary
model: anthropic/claude-sonnet-4   # only if modelOverrides.<slug> is set
permission:
  bash:
    "*": ask
    "git status*": allow
    "rm *": ask
  edit: allow
---
<systemPrompt body>
```

**Arguments**:

| Arg             | Type                | Meaning                                            |
| --------------- | ------------------- | -------------------------------------------------- |
| `pkgs`          | nixpkgs set         | For `linkFarm`/`writeText`.                         |
| `canonical`      | attrset             | Output of `loadCanonical`.                          |
| `modelOverrides`| attrset (optional)  | e.g. `{ chiron = "anthropic/claude-sonnet-4"; }`.   |

**Internal helpers**:

- `renderPermSection tool section` — turn one permission section into YAML
  lines. Two shapes:
  - **intent-only** (no `rules` or `rules == []`): one line `  <tool>: <intent>`.
  - **intent + rules**: a nested block with a wildcard line (`"*": intent`)
    plus one line per pattern.
- `renderPermBlock permissions` — collapse all sections into the
  `permission:` block (or `[]` if empty).
- `mkFrontmatter name agent` — assemble frontmatter string from description,
  mode, optional modelOverride, optional permission block.
- `mkAgentContent name agent` — frontmatter + `agent.systemPrompt`.

**Permission DSL → OpenCode YAML example**:

Canonical rule `"git push origin:allow"` becomes:

```yaml
permission:
  bash:
    "*": ask            # wildcard, intent from section
    "git push origin": allow
```

---

### `renderForClaudeCode`

```nix
renderForClaudeCode = { pkgs, canonical, modelOverrides ? {} }: storePath;
```

**Purpose**: Produce a directory for [Claude Code](https://www.anthropic.com/claude-code)
containing:

```
.claude/
  agents/
    <slug>.md       — one per agent (YAML frontmatter + systemPrompt)
  settings.json     — aggregated permission rules in Claude Code DSL
```

**Claude Code specific constraints**:

- Agent name field must be **kebab-case**: `[a-z0-9-]+`.
- `description` is required.
- **No primary/subagent distinction** — all agents are subagents in Claude
  Code.
- Permissions aren't per-agent — they're aggregated into a single
  `settings.json`.

**Output file format** (one `*.md` per agent):

```markdown
---
description: "Explore agent"
model: claude-3-5-sonnet        # only if modelOverrides.<slug> is set
skills:                          # only present if agent.skills is non-empty
  - task-management
  - blog-writer
---
<systemPrompt body>
```

**`settings.json` format** (aggregated across all agents):

```json
{
  "permissions": {
    "allow": ["Bash", "Edit", "WebFetch"],
    "deny":  ["Bash(rm -rf *)", "Edit(/run/agenix/**)"]
  }
}
```

**Internal helpers**:

- `renderPermAllow permissions` — collect allow rules for `Bash`, `Edit`, and
  `WebFetch`. For each tool:
  - If `intent == "allow"` → emit bare tool name (e.g. `"Bash"` — full
    permission).
  - Otherwise, filter the rule list for `action == "allow"` patterns and emit
    `Bash(<pattern>)` for each one.
- `renderPermDeny permissions` — same shape, but for `action == "deny"` rules
  (no bare-tool deny; always pattern-specific).
- `mkClaudeFrontmatter name agent` — description line + optional model +
  optional `skills:` list.
- `mkClaudeAgentContent` — frontmatter + `systemPrompt`.
- Aggregation: `allAllows` / `allDenies` are flattened from all agents, then
  `lib.unique (lib.sort ...)` produces a clean, deterministic list.

**Build step**: Uses `pkgs.runCommand` to:

1. `mkdir -p $out/.claude/agents`
2. `cp -r ${agentFiles}/* $out/.claude/agents/`
3. `cp ${settingsFile} $out/.claude/settings.json`

---

### `renderForPi`

```nix
renderForPi =
  { pkgs, canonical, modelOverrides ? {}, primaryAgent ? null, codingRules ? null }:
  storePath;
```

**Purpose**: Produce a directory for the **Pi** harness with:

```
AGENTS.md              — primary agent description + specialists listing + optional coding rules
SYSTEM.md              — primary agent's systemPrompt (replaces Pi's default)
agents/
  <slug>.md            — one per agent (pi-subagents frontmatter + systemPrompt)
```

**Pi-specific** (vs OpenCode/Claude Code):

- **Primary/subagent distinction** is explicit: there must be exactly one
  agent with `mode = "primary"`; the rest are listed as specialists.
- The `agents/*.md` files use the **pi-subagents** frontmatter schema:
  `name`, `description`, `tools`, `extensions`, `model`, `thinking`, `skill`,
  `output`, `defaultReads`, `defaultProgress`, `interactive`,
  `maxSubagentDepth`. (This lib currently populates `name`, `description`,
  `tools`, `model`, `skill`.)
- Pi has **no per-pattern permission granularity** — only per-tool
  include/exclude. So canonical intent + rules collapse to a simple tool
  list.

**Arguments**:

| Arg             | Type                | Meaning                                                |
| --------------- | ------------------- | ------------------------------------------------------ |
| `pkgs`          | nixpkgs set         | For `linkFarm` / `writeText` / `runCommand`.            |
| `canonical`     | attrset             | Output of `loadCanonical`.                              |
| `modelOverrides`| attrset (optional)  | Override model per agent slug.                          |
| `primaryAgent`  | string (optional)   | Force which agent is primary (default: the one with `mode = "primary"`). |
| `codingRules`   | attrset (optional)  | Passed to `./coding-rules.nix` to append a rules section to `AGENTS.md`. |

**Throws** if no primary agent is found (and `primaryAgent` wasn't passed).

**Internal helpers**:

- `piToolsForAgent agent` — translate canonical permission intents to a Pi
  tool list:
  ```
  canonical intent   →  Pi tool
  bash               →  "bash"
  edit               →  "edit"
  webfetch           →  "fetch_content"
  websearch          →  "web_search"
  ```
  - `intent == "allow"` OR `"ask"` → tool **included** (Pi has no ask).
  - `intent == "deny"` → tool **excluded**.
  - `read`, `grep`, `find`, `ls` are **always included** (no permission
    concept in Pi).
  - When rules exist with `intent=allow`, tool is included regardless (we
    can't express pattern-restriction in Pi, so we err on the side of
    inclusion).
- `mkPiFrontmatter name agent` — emits:
  ```yaml
  ---
  name: <slug>
  description: "..."
  tools: read, grep, find, ls, bash, edit
  model: <override>      # optional
  skill: <skills>        # optional, comma-separated if agent.skills non-empty
  ---
  ```
- `mkPiAgentContent` — frontmatter + `systemPrompt`.

**`AGENTS.md` content** (top-level):

```markdown
# Agent Instructions

## <primary display_name>

<primary.description>

## Available Specialists

- **Explore**: Find files by pattern and search code for keywords.
- **Writer**: Write conversational blog posts.
...
< optional coding-rules markdown section >
```

- `primaryDn` = `primary.display_name or primaryName` (the primary's slug).
- `specialistEntries` — one `- **<display_name>**: <description>` per
  subagent.
- `codingRulesSection` — when `codingRules != null`, calls
  `./coding-rules.nix`'s `mkRulesMdSection` and appends the result.

**Build step**: `pkgs.runCommand` does:

1. `mkdir -p $out/agents`
2. `cp $agentsMdFile $out/AGENTS.md`
3. `cp $systemMdFile $out/SYSTEM.md`
4. `cp -r ${piAgentFiles}/* $out/agents/`

---

### `renderForTool` (dispatcher)

```nix
renderForTool =
  { pkgs, agentsInput, tool, modelOverrides ? {}, codingRules ? null }:
  storePath;
```

**Purpose**: Single entry-point that picks the right renderer based on `tool`.
Most call sites should use this instead of calling a renderer directly — it
also re-runs `loadCanonical` internally so you don't have to.

**Arguments**:

| Arg             | Type                              | Meaning                          |
| --------------- | --------------------------------- | -------------------------------- |
| `pkgs`          | nixpkgs set                       | Passed through.                  |
| `agentsInput`   | flake input                       | Used for `loadCanonical`.         |
| `tool`          | `"opencode" \| "claude-code" \| "pi"` | Required.                  |
| `modelOverrides`| attrset (optional)                | Per-slug model override.         |
| `codingRules`   | attrset (optional)                 | Only used by Pi renderer.        |

**Behavior**:

```nix
if tool == "opencode"     then renderForOpencode     { ... }
else if tool == "claude-code" then renderForClaudeCode { ... }
else if tool == "pi"       then renderForPi           { ... codingRules ... }
else throw "unknown tool '<tool>'. Must be opencode, claude-code, or pi."
```

**Returns**: Whatever store path the chosen renderer returns.

---

### `shellHookForTool`

```nix
shellHookForTool =
  { pkgs, agentsInput, tool, modelOverrides ? {}, codingRules ? null }:
  string;
```

**Purpose**: Generate a **shell script snippet** (string) you can drop into a
`devShells.<name>.shellHook` so that entering the shell symlinks the rendered
agent files into the project directory (under `.opencode/`, `.claude/`, or
`.pi/`). Convenience wrapper around `renderForTool`.

**Outputs by tool**:

- `opencode`:
  ```bash
  mkdir -p .opencode/agents
  ln -sfn ${rendered}/* .opencode/agents/
  ```
- `claude-code`:
  ```bash
  mkdir -p .claude/agents
  ln -sfn ${rendered}/.claude/agents/* .claude/agents/
  ln -sfn ${rendered}/.claude/settings.json .claude/settings.json
  ```
- `pi`:
  ```bash
  ln -sfn ${rendered}/AGENTS.md AGENTS.md
  mkdir -p .pi
  ln -sfn ${rendered}/SYSTEM.md .pi/SYSTEM.md
  mkdir -p .pi/agents
  ln -sfn ${rendered}/agents/* .pi/agents/
  ```

**Usage example** (in your `flake.nix` / a `flake-parts` module):

```nix
devShells.default = pkgs.mkShell {
  shellHook = m3taLib.agents.shellHookForTool {
    inherit pkgs;
    agentsInput = inputs.agents;
    tool = "opencode";
    modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
  };
};
```

**Throws** if `tool` is unrecognized.

**Safety**: Uses `ln -sfn` (force + no-deref), so re-entering the devShell
cleans up stale symlinks without error.

---

## End-to-end usage example

```nix
let
  m3taLib = inputs.m3ta-nixpkgs.lib.${system};

  # 1. Load canonical agents from the AGENTS flake input.
  canonical = m3taLib.agents.loadCanonical {
    agentsInput = inputs.agents;
  };

  # 2. Render for OpenCode with a model override on the "chiron" agent.
  opencodeRendered = m3taLib.agents.renderForOpencode {
    inherit pkgs canonical;
    modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
  };
in
{
  # 3. Wire it into your NixOS / home-manager config as a symlinked dir.
  xdg.configFile."opencode/agents".source = opencodeRendered;

  # Or in a devShell:
  devShells.default = pkgs.mkShell {
    shellHook = m3taLib.agents.shellHookForTool {
      inherit pkgs;
      agentsInput = inputs.agents;
      tool = "opencode";
      modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
    };
  };
}
```

---

## Mental model / design notes

1. **Pure functions.** Every renderer is`pkgs + canonical + overrides → store path`.
   No hidden state, easy to test, cacheable.

2. **Single source of truth → many formats.** You describe your agents once
   (in the AGENTS flake). This lib adapts that description for each harness.
   Adding a new harness = writing one new renderer function.

3. **Adapter pattern.** The permission model is intentionally lossy in places:
   - Pi has no per-pattern rules → canonical intents collapse to a tool list.
   - Claude Code aggregates permissions across all agents → no per-agent
     permission blocks.
   - OpenCode preserves full fidelity (per-pattern + per-intent).

4. **Two layers of dispatch.**
   - `renderForTool` for "render and consume the store path directly."
   - `shellHookForTool` for "render and wire into a devShell."

5. **`linkFarm` for file trees.** Cheap, symlink-only outputs — perfect for
   "files that get symlinked into a config dir."

6. **`runCommand` for compound outputs.** Used by renderers that need to emit
   multiple file types at once (Claude Code: `agents/` + `settings.json`; Pi:
   `AGENTS.md` + `SYSTEM.md` + `agents/`).

7. **Idempotent outputs.** `lib.unique (lib.sort (a: b: a < b) ...)` for the
   Claude Code permission list ensures the same canonical input always
   produces bit-identical output (good for cache hits and reviewability).