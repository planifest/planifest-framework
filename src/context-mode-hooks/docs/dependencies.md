# Dependencies — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.2.0

---

## Runtime Dependencies

| Dependency | Type | Required | Version | Notes |
|------------|------|----------|---------|-------|
| `node` (Node.js) | System tool | Yes | ≥ 18 | Sole runtime — hooks are `.mjs`, invoked as `node <script>` on every platform (0000017 req-004, ADR-002). Available wherever Claude Code is installed. If missing, setup warns at install time and the wired command surfaces a runtime message while failing open. |

> `bash`, `jq`, `awk`, and `grep` were removed as dependencies by the 0000017 `.mjs` port — parsing, token extraction, and pattern matching are native JavaScript. (The component's *test suite* still uses bash, as does the rest of the framework's test harness — a dev-time dependency only, not a runtime one.)

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

No drift detected (re-verified 0000017 P6). The sole runtime dependency declared above is consistent with the `.mjs` scripts at `planifest-framework/hooks/context-mode/` — Node built-ins only, no external imports.

---

## Dependency Direction Rule

This component imports only Node.js built-ins. It has no build system and no external packages. No direction violations possible.
