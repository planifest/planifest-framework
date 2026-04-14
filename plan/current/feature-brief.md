# Feature Brief - Structured Telemetry Framework Integration

**Feature ID:** 0000002-structured-telemetry-framework-integration
**Source:** Roadmap Item 0008b — Planifest Framework Review (April 2026) → Section 4: The Tooling Ecosystem & Observability
**Requested by:** Martin Mayer — April 2026
**Planifest Rating:** 🟠 Developing

---

## Observation

Once the Structured Telemetry MCP Server (0008a) is deployed, the Planifest framework must be wired to use it. This requires an explicit opt-in mechanism in the setup scripts and precise telemetry sections in each agent skill so that events are emitted consistently and with the correct data shape.

## Recommendation

Wire the Planifest framework to the telemetry service via an explicit `--structured-telemetry-mcp` setup flag. Update agent skills with structured Telemetry sections specifying exact event types and required data fields. Install a combined context-pressure hook when both `--structured-telemetry-mcp` and `--context-mode-mcp` are active.

---

## Design Goals

1. **Explicit opt-in.** Telemetry is disabled by default. Only activated when `--structured-telemetry-mcp` is passed to the setup script.
2. **Zero fallback.** If the MCP server is not provisioned, no telemetry is emitted. No local file fallbacks.
3. **Tool-presence gating.** Agents check for the `emit_event` tool before any emission attempt. If absent, skip silently.
4. **Schema-strict payloads.** Skill Telemetry sections specify exact required fields to match the server's `additionalProperties: false` schema.
5. **Context-mode ready.** When both flags are active, a hook captures `context_pressure` events automatically.

---

## Prerequisites

The HTTP backend service (0008a) must be running before setup is executed. The service owns the single DuckDB connection that all MCP stdio sessions write through.

```powershell
# Windows — run once as administrator
.\scripts\deploy.ps1
```

```bash
# macOS / Linux — run once
./scripts/deploy.sh
```

Verify:
```
curl http://127.0.0.1:3741/health   # → {"ok":true,"version":"0.1.0"}
```

---

## Setup Flag

The framework `setup.ps1` / `setup.sh` scripts accept `--structured-telemetry-mcp` after the tool argument:

```powershell
.\planifest-framework\setup.ps1 claude-code --structured-telemetry-mcp
.\planifest-framework\setup.ps1 claude-code --context-mode-mcp --structured-telemetry-mcp
```

```bash
./planifest-framework/setup.sh claude-code --structured-telemetry-mcp
./planifest-framework/setup.sh claude-code --context-mode-mcp --structured-telemetry-mcp
```

Optional `--backend-url` override:

```powershell
.\planifest-framework\setup.ps1 claude-code --structured-telemetry-mcp --backend-url http://localhost:3741
```

### What the flag does

1. **Installs telemetry hooks in the project folder.** MCP server registration is handled by the deploy and setup scripts in the 0008a MCP repo — not here. This flag installs the telemetry hooks into `.claude/hooks/telemetry/` and wires them in `.claude/settings.json` for this workspace.

2. **Does not restart the tool.** The user must restart their agentic tool after setup.
3. **Does not register a hook by itself.** The `context_pressure` hook is only installed when `--context-mode-mcp` is also present.

---

## Dependencies

| Dependency | Required for |
|---|---|
| **0008a** — Structured Telemetry MCP Server | The ingestion backend. Must be deployed and running before setup. |
| **0006c** — context-mode MCP | Automated `context_pressure` events via `PostToolUse` hook. Without it, pressure data requires manual emission. |
