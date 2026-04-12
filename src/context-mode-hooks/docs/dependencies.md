# Dependencies — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.1.0

---

## Runtime Dependencies

| Dependency | Type | Required | Version | Notes |
|------------|------|----------|---------|-------|
| `bash` | System tool | Yes | ≥ 4.0 | Scripts use `#!/usr/bin/env bash` and `set -euo pipefail`. Bash 4+ is standard on Linux/macOS. On Windows, Git Bash or WSL required. |
| `jq` | System tool | Recommended | any | Used for JSON parsing and output construction. If absent, falls back to Node.js. Install via `brew install jq` / `scoop install jq`. See quirks Q-002. |
| `node` (Node.js) | System tool | Fallback | ≥ 18 | Used as `jq` fallback. Available wherever Claude Code is installed. |
| `awk` | System tool | Yes | any | Used in `block-bash.sh` for leading-token extraction. Present on all POSIX systems including Git Bash. |
| `grep` | System tool | Yes | any | Used in `block-bash.sh` for pattern matching against the command string. Standard system tool. |

---

## What Consumes This Component

| Consumer | Type | How |
|----------|------|-----|
| Claude Code | Runtime host | Invokes hook scripts via `PreToolUse` hook configuration in `.claude/settings.json` |
| `setup.sh` / `setup.ps1` | Installer | Copies hook scripts and writes settings.json entries |

---

## What This Component Consumes

| Dependency | Type | How |
|------------|------|-----|
| Claude Code hook runner | Platform | Provides stdin payload; reads stdout decision |
| context-mode MCP server | Conceptual | Hooks redirect agents to `ctx_execute`, `ctx_fetch_and_index`, `ctx_search` — the MCP server must be installed separately |

> **Note:** The hooks do not call the context-mode MCP server directly. They only emit text instructions naming the MCP tools. The MCP server must be configured separately (via `setup.sh claude-code --context-mode-mcp` or equivalent).

---

## Declared vs. Actual Dependencies (Drift Check)

No drift detected. All runtime dependencies declared above are consistent with the shell scripts at `planifest-framework/hooks/context-mode/`.

---

## Dependency Direction Rule

This component has no import/require statements. It has no build system. All dependencies are invoked as shell commands (`jq`, `node`, `awk`, `grep`). No direction violations possible.
