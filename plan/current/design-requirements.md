# Design Requirements - 0000002-structured-telemetry-framework-integration

---

## Functional Requirements

### REQ-001 — Setup flag: `--structured-telemetry-mcp`
**Priority:** Must
`setup.sh` and `setup.ps1` MUST accept `--structured-telemetry-mcp`. When present, the setup script installs telemetry hooks into `.claude/hooks/telemetry/` and wires them in `.claude/settings.json` for this workspace. MCP server registration is handled by the deploy and setup scripts in the 0008a MCP repo and is not repeated here.

### REQ-002 — Backend URL override
**Priority:** Should
The setup scripts SHOULD accept an optional `--backend-url <url>` argument overriding the default backend address (`http://localhost:3741`).

### REQ-003 — MCP server registration format
**Priority:** Must
The MCP server entry MUST use `command + args` (stdio proxy) format — NOT an SSE URL. The entry must be identical in shape across Claude Code (`~/.claude/settings.json`), Claude Desktop (`claude_desktop_config.json`), and Cursor (`.cursor/mcp.json`).

### REQ-004 — Tool-presence and opt-in gating
**Priority:** Must
Every agent skill MUST satisfy both conditions before any emission attempt:
1. The `emit_event` tool is present in the current session.
2. The file `.claude/telemetry-enabled` exists in the project root.

The sentinel file is written by setup when `--structured-telemetry-mcp` is passed. If either condition is not met, the skill MUST proceed silently — no error, no fallback write, no mention to the user. This ensures that a globally-registered MCP server does not cause emission in projects that have not opted in.

### REQ-005 — `phase_start` / `phase_end` events
**Priority:** Must
All 8 affected skills MUST emit `phase_start` before task entry and `phase_end` after task exit when `emit_event` is available. `phase_end` MUST include `status` (`"pass"` | `"fail"`) and `duration_ms`.

### REQ-006 — Skill-specific event types
**Priority:** Must
Each skill MUST emit only the event types defined in its Telemetry section. No skill may emit event types not assigned to it:
- **orchestrator:** `phase_start`, `phase_end`, `phase_skip`, `spec_gap`, `mcp_impact`
- **spec-agent:** `phase_start`, `phase_end`, `spec_gap`
- **adr-agent:** `phase_start`, `phase_end`, `adr_decision`
- **codegen-agent:** `phase_start`, `phase_end`, `deviation`, `migration_proposal`, `self_correction`, `retry_limit_exceeded`
- **validate-agent:** `phase_start`, `phase_end`, `validation_failure`, `self_correction`, `retry_limit_exceeded`
- **change-agent:** `phase_start`, `phase_end`, `deviation`, `migration_proposal`, `self_correction`, `retry_limit_exceeded`
- **security-agent:** `phase_start`, `phase_end`, `security_finding`, `deviation`
- **docs-agent:** `phase_start`, `phase_end`, `doc_gap`, `deviation`

> **Note:** All 14 event types are live (0008c deployed and verified 2026-04-14).

### REQ-007 — Schema-strict payloads
**Priority:** Must
All `data` payloads MUST include exactly the required fields defined per event type. No additional properties. The server enforces `additionalProperties: false`.

### REQ-008 — Context pressure hook
**Priority:** Should
When both `--structured-telemetry-mcp` and `--context-mode-mcp` are active, setup MUST install `context-pressure.mjs` to `.claude/hooks/telemetry/` and register it as a `PostToolUse` hook in `.claude/settings.json`. The hook emits `context_pressure` when context fill % exceeds 70% (default threshold).

### REQ-009 — No tool restart on setup
**Priority:** Must
The setup script MUST NOT restart the agentic tool. The user is responsible for restarting after setup.

### REQ-009b — mcp_impact event (orchestrator, end of run)
**Priority:** Should
`planifest-orchestrator` SHOULD emit `mcp_impact` once at the end of a complete pipeline run, after the final `phase_end`. Required fields: `mcp_mode`, `avg_token_delta`, `peak_fill_pct`. Fully implemented in the 0008a server schema and documented in the MCP README — confirmed via live exploration 2026-04-14.

### REQ-009c — model_config envelope field
**Priority:** May
Any skill MAY populate the optional `model_config` envelope field to record tool-specific model settings at emission time (e.g. `{ "effort": "high" }`, `{ "thinking": true, "budget_tokens": 10000 }`). Fully implemented in the 0008a server schema. Omit if not relevant.

### REQ-010 — Hook requires both flags
**Priority:** Must
The `context-pressure` hook MUST NOT be installed unless both `--structured-telemetry-mcp` and `--context-mode-mcp` are present. The `--structured-telemetry-mcp` flag alone MUST NOT install any hooks.

---

## Non-Functional Requirements

### NFR-001 — Silent failure
Telemetry failures MUST NOT surface to the user or interrupt agent operation.

### NFR-002 — No local fallback
If the MCP server is unavailable, zero telemetry is emitted. No file writes, no queuing, no retry.

### NFR-003 — Envelope completeness
Every event MUST carry all envelope fields. `mcp_mode` MUST be determined at session start and stamped on every event.
