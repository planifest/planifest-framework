# Scope - 0000002-structured-telemetry-framework-integration

---

## In Scope

- `--structured-telemetry-mcp` flag added to `setup.sh` and `setup.ps1`
- Optional `--backend-url <url>` argument overriding the default backend address (`http://localhost:3741`)
- MCP server registered in tool configuration files using `command + args` stdio format:
  - Claude Code: `~/.claude/settings.json`
  - Claude Desktop: `claude_desktop_config.json`
  - Cursor: `.cursor/mcp.json`
- Telemetry sections added to 8 SKILL.md files:
  - `planifest-orchestrator` — `phase_start`, `phase_end`, `spec_gap`
  - `planifest-spec-agent` — `phase_start`, `phase_end`, `spec_gap`
  - `planifest-adr-agent` — `phase_start`, `phase_end`
  - `planifest-codegen-agent` — `phase_start`, `phase_end`, `deviation`, `migration_proposal`, `self_correction`
  - `planifest-validate-agent` — `phase_start`, `phase_end`, `validation_failure`, `self_correction`
  - `planifest-change-agent` — `phase_start`, `phase_end`, `deviation`, `migration_proposal`, `self_correction`
  - `planifest-security-agent` — `phase_start`, `phase_end`, `deviation`
  - `planifest-docs-agent` — `phase_start`, `phase_end`, `deviation`
- `hooks/telemetry/context-pressure.mjs` — new hook installed to `.claude/hooks/telemetry/` and registered as `PostToolUse` in `.claude/settings.json` **only** when both `--structured-telemetry-mcp` and `--context-mode-mcp` are active
- Claude Code support

---

## Out of Scope

- Building or modifying the Structured Telemetry MCP Server (owned by 0008a)
- Auto-discovery of a running backend — explicit flag always required
- Local schema copy or validation — server enforces schema at ingestion
- Hook support for Cursor, Windsurf, Cline, Antigravity (no confirmed `PostToolUse` equivalent)
- Telemetry dashboard or query tooling

---

## Deferred

- Cursor / other tool hook wiring — deferred until hook architectures are confirmed per tool
- Configurable threshold for `context_pressure` hook (hardcoded at 70% for v1)
- Retry or buffering for failed `emit_event` calls
- Additional event types beyond those defined in the spec (e.g. `token_usage`, `cost_estimate`)
