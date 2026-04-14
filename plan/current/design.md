# Design - 0000002-structured-telemetry-framework-integration

**Status:** draft
**Version:** 0.1.0

---

## Feature

- **Problem:** Agent behaviour across pipeline phases is unobservable. No structured telemetry is emitted by framework skills. Deviations, spec gaps, self-corrections, and validation failures are invisible unless printed to the conversation.
- **Adoption mode:** retrofit (existing setup scripts + skill files)
- **Feature ID:** 0000002-structured-telemetry-framework-integration

---

## Product Layer

- User stories: 3
  1. As an operator, I want to see when each pipeline phase starts and ends so I can identify bottlenecks.
  2. As an operator, I want to capture spec gaps and deviations so I can audit framework quality over time.
  3. As an operator, I want context pressure events captured automatically so I can correlate context usage with agent behaviour.
- Acceptance criteria: 5
  1. `--structured-telemetry-mcp` flag installs telemetry hooks in the project folder and wires them in `.claude/settings.json`.
  2. Each agent skill emits `phase_start` and `phase_end` events at task boundaries when `emit_event` is available.
  3. No event is emitted when `emit_event` tool is absent — agent proceeds silently.
  4. Context pressure hook is installed only when both `--structured-telemetry-mcp` and `--context-mode-mcp` flags are active.
  5. All emitted payloads match the server's strict schema (`additionalProperties: false`).
- Constraints: No local file fallbacks. No auto-discovery. Tool presence checked before every emission.
- Integrations: Structured Telemetry MCP Server (0008a) via stdio proxy → HTTP backend at `http://localhost:3741`

---

## Architecture Layer

- Latency target: < 5ms per `emit_event` call (async fire-and-forget in MCP transport)
- Availability target: not applicable — telemetry is best-effort; failures are silent
- Security: no credentials, no sensitive data. Hook reads context fill % only. No tool input is logged.
- Data privacy: no regulated data
- Cost boundary: not constrained

---

## Engineering Layer

- Stack: PowerShell + bash (setup scripts) / Markdown (SKILL.md updates) / JavaScript ESM (hook script) / JSON (settings wiring)
- Components:
  - **`setup-telemetry-flag`** — changes to `setup.sh` and `setup.ps1` adding `--structured-telemetry-mcp` flag and optional `--backend-url` override. Installs telemetry hooks into `.claude/hooks/telemetry/` and wires them in `.claude/settings.json` for the workspace. MCP server registration is handled by the 0008a deploy/setup scripts.
  - **`skill-telemetry-sections`** — Telemetry sections added to 8 SKILL.md files: orchestrator, spec-agent, adr-agent, codegen-agent, validate-agent, change-agent, security-agent, docs-agent.
  - **`context-pressure-hook`** — new `hooks/telemetry/context-pressure.mjs`. Installed to `.claude/hooks/telemetry/` and registered as `PostToolUse` in `settings.json` only when both flags are active.
- Data ownership: no data owned — framework emits events only; DuckDB is owned by 0008a
- Deployment: local only — scripts run at setup time; hook files copied to `.claude/hooks/telemetry/`

---

## Event Envelope

Every event shares this envelope:

| Field | Source |
|---|---|
| `schema_version` | Always `"1.0"` |
| `event` | Specific event type |
| `session_id` | context-mode session ID if available; otherwise `crypto.randomUUID()` per run |
| `initiative_id` | Feature ID from `plan/current/design.md` header; omit if not in a pipeline run |
| `phase` | Current pipeline phase name |
| `agent` | Skill name |
| `tool` | Agentic tool: `claude-code`, `cursor`, etc. |
| `model` | Model identifier, e.g. `claude-sonnet-4-6` |
| `mcp_mode` | `none` \| `workspace` \| `context` \| `workspace+context` — determined at session start |
| `timestamp` | ISO 8601 at point of emission |
| `model_config` | Optional. Free-form object for tool-specific model settings, e.g. `{ "effort": "high" }` or `{ "thinking": true, "budget_tokens": 10000 }`. Omit if not relevant. |
| `data` | Typed payload per event schema |

### `mcp_mode` determination

| Active setup flags | `mcp_mode` value |
|---|---|
| Neither `--mcp-workspace` nor `--context-mode-mcp` | `"none"` |
| `--mcp-workspace` only | `"workspace"` |
| `--context-mode-mcp` only | `"context"` |
| Both | `"workspace+context"` |

---

## Skill Telemetry Sections

### planifest-orchestrator

**phase_start** — emit before delegating to any phase skill:
```json
{ "phase_name": "<current phase name>" }
```

**phase_end** — emit after each phase skill returns:
```json
{ "phase_name": "<phase>", "status": "pass" | "fail", "duration_ms": <elapsed> }
```

**phase_skip** — emit when a phase is determined unnecessary and bypassed:
```json
{ "phase_name": "<skipped phase>", "reason": "<why it was skipped>" }
```

**spec_gap** — emit when human clarification is required before proceeding:
```json
{ "question": "<the question being asked>", "phase_name": "<current phase>" }
```

**mcp_impact** — emit once at the end of a complete pipeline run, after the final `phase_end`:
```json
{ "mcp_mode": "<active mode>", "avg_token_delta": <number>, "peak_fill_pct": <number> }
```
Query with `{ "mode": "mcp_impact" }` to compare token impact across MCP configurations. `group_by: "mcp_mode"` on bottleneck queries will also work once BUG-001 in 0008c is deployed.

---

### planifest-spec-agent

**phase_start** at task entry. **phase_end** at task exit.

**spec_gap** when the spec cannot proceed without human input:
```json
{ "question": "<blocking question>", "phase_name": "spec" }
```

---

### planifest-adr-agent

**phase_start** at task entry. **phase_end** at task exit.

**adr_decision** after each ADR is written:
```json
{ "adr_id": "ADR-001", "title": "<decision title>", "chosen_option": "<the option selected>" }
```

---

### planifest-codegen-agent, planifest-change-agent

**phase_start** / **phase_end** at task boundaries.

**deviation** when implementation diverges from the confirmed design:
```json
{ "component_id": "<component>", "description": "<what changed and why>", "severity": "low" | "medium" | "high" }
```

**migration_proposal** when a schema change is required (before writing the proposal file):
```json
{ "component_id": "<component>", "proposal_path": "src/<id>/docs/migrations/proposed-<desc>.md", "destructive": true | false }
```

**self_correction** when retrying a failed action:
```json
{ "phase_name": "<phase>", "attempt_number": <n>, "action_id": "<action>", "correction_type": "<type>" }
```

**retry_limit_exceeded** when the 5-attempt escalation ceiling is hit:
```json
{ "phase_name": "<phase>", "action_id": "<action>", "attempt_count": 5 }
```

---

### planifest-validate-agent

**phase_start** / **phase_end** at task boundaries.

**validation_failure** for each test or check failure:
```json
{ "failure_type": "<test|lint|type|build>", "phase_name": "validate", "attempt_number": <n>, "action_id": "<test suite or check name>" }
```

**self_correction** when retrying after a failure:
```json
{ "phase_name": "validate", "attempt_number": <n>, "action_id": "<action>", "correction_type": "fix_and_retry" }
```

**retry_limit_exceeded** when the 5-attempt escalation ceiling is hit:
```json
{ "phase_name": "validate", "action_id": "<action>", "attempt_count": 5 }
```

---

### planifest-security-agent

**phase_start** / **phase_end** at task boundaries.

**security_finding** for each vulnerability or risk identified:
```json
{ "component_id": "<component>", "title": "<short description>", "severity": "low" | "medium" | "high" | "critical", "cwe": "<CWE-NNN — optional>" }
```

**deviation** if the output diverges from the confirmed design (non-security):
```json
{ "component_id": "<component>", "description": "<deviation>", "severity": "low" | "medium" | "high" }
```

---

### planifest-docs-agent

**phase_start** / **phase_end** at task boundaries.

**doc_gap** when documentation is missing or incomplete for a component:
```json
{ "component_id": "<component>", "description": "<what is missing>" }
```

**deviation** if the output diverges from the confirmed design:
```json
{ "component_id": "<component>", "description": "<deviation>", "severity": "low" | "medium" | "high" }
```

---

## Context Pressure Hook

When both `--structured-telemetry-mcp` and `--context-mode-mcp` are active, setup installs a `PostToolUse` hook that reads the current context fill % after each tool call and emits `context_pressure` if it exceeds 70% (default threshold).

```json
{
  "event": "context_pressure",
  "data": {
    "context_fill_pct": 78.5,
    "unused_sources": ["design.md", "ADR-003"],
    "trigger": "threshold_exceeded"
  }
}
```

Installed at: `.claude/hooks/telemetry/context-pressure.mjs`
Registered in: `.claude/settings.json` as `PostToolUse`

---

## Files Changed

| File | Change |
|---|---|
| `planifest-framework/setup.sh` | Add `--structured-telemetry-mcp` flag; write sentinel; install hooks |
| `planifest-framework/setup.ps1` | Same (PowerShell) |
| `.claude/telemetry-enabled` | Sentinel written by setup; skills gate on this + `emit_event` presence |
| `planifest-framework/hooks/telemetry/context-pressure.mjs` | New hook |
| `skills/planifest-orchestrator/SKILL.md` | Add Telemetry section |
| `skills/planifest-spec-agent/SKILL.md` | Add Telemetry section |
| `skills/planifest-adr-agent/SKILL.md` | Add Telemetry section |
| `skills/planifest-codegen-agent/SKILL.md` | Add Telemetry section |
| `skills/planifest-validate-agent/SKILL.md` | Add Telemetry section |
| `skills/planifest-change-agent/SKILL.md` | Add Telemetry section |
| `skills/planifest-security-agent/SKILL.md` | Add Telemetry section |
| `skills/planifest-docs-agent/SKILL.md` | Add Telemetry section |

---

## Resolved Questions

1. **Auto-discovery:** The setup script does not auto-discover a running server. The `--structured-telemetry-mcp` flag is always required. ✅
2. **Schema bundling:** The framework does not bundle a local copy of the schema. Validation is performed exclusively by the MCP server at ingestion time. ✅
3. **MCP config format:** `command + args` (stdio proxy → HTTP backend). Not SSE URL. Works identically across Claude Code, Claude Desktop, and Cursor. ✅
4. **New event types (`phase_skip`, `security_finding`, `retry_limit_exceeded`, `adr_decision`, `doc_gap`):** Not yet in the 0008a server schema. 0008c must be implemented and deployed before these events can be emitted. ✅ (tracked in `docs/0008c`)
5. **`mcp_impact` and `model_config`:** Both are fully implemented and documented in the 0008a MCP repo. They were absent from 0008b — now corrected in this design. ✅

---

## Dependencies

- Upstream: 0008a Structured Telemetry MCP Server (backend must be running before setup)
- Upstream: **0008c** Structured Telemetry MCP Changes — new event types (`phase_skip`, `security_finding`, `retry_limit_exceeded`, `adr_decision`, `doc_gap`) require 0008c schema additions before they can be emitted
- Upstream: 0006c context-mode MCP (required only for automated `context_pressure` events)
- Downstream: none

## Confirmation

Human confirmed this design before proceeding: no
