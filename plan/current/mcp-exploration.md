# MCP Exploration — Structured Telemetry MCP

**Explored:** 2026-04-14
**Session:** test-explore-001

---

## emit_event

### Accepted event types (9 total)

| Event | Data fields (all required, no extras) | Confirmed |
|---|---|---|
| `phase_start` | `{ phase_name }` | ✅ |
| `phase_end` | `{ phase_name, status: "pass"\|"fail", duration_ms }` | ✅ |
| `spec_gap` | `{ question, phase_name }` | ✅ |
| `deviation` | `{ component_id, description, severity: "low"\|"medium"\|"high" }` | ✅ |
| `migration_proposal` | `{ component_id, proposal_path, destructive: bool }` | ✅ (from schema) |
| `validation_failure` | `{ failure_type, phase_name, attempt_number, action_id }` | ✅ (from schema) |
| `self_correction` | `{ phase_name, attempt_number, action_id, correction_type }` | ✅ |
| `context_pressure` | `{ context_fill_pct, unused_sources, trigger }` | ✅ (from schema) |
| `mcp_impact` | `{ mcp_mode, avg_token_delta, peak_fill_pct }` | ✅ **undocumented in 0008b** |

### mcp_impact — undocumented event

Found by probing the oneOf validation error. Not mentioned in 0008b. Fields:
- `mcp_mode` — the active MCP mode for the session (`none`, `workspace`, `context`, `workspace+context`)
- `avg_token_delta` — average token count change per tool call across the session
- `peak_fill_pct` — highest context fill % reached during the session

**Likely intent:** emitted by the orchestrator at end of a pipeline run to capture aggregate MCP impact — the primary dimension for measuring context-mode effectiveness over time.

### Rejected proposed event types

These are not in the server's allowed values list. They would require a schema update to 0008a before they can be used:

| Event | Status |
|---|---|
| `phase_skip` | ❌ not in schema |
| `security_finding` | ❌ not in schema |
| `retry_limit_exceeded` | ❌ not in schema |
| `adr_decision` | ❌ not in schema |

### Schema enforcement

- `additionalProperties: false` enforced on every `data` payload
- Event name must match exact allowed values — unknown names are rejected immediately
- Validation errors expose the full oneOf schema via error messages (useful for schema discovery)

---

## query_telemetry

### Working query shape

```json
{ "group_by": "<column>", "filter": { "<field>": "<value>" } }
```

`group_by` and `filter` are the only confirmed working keys. A bare `{}` or `{ "mode": "..." }` returns "Unrecognised query shape".

### Valid group_by columns

| Column | Result |
|---|---|
| `agent` | ✅ Returns duration stats grouped by agent |
| `phase` | ✅ Returns duration stats grouped by phase |
| `event` | ❌ Backend 400 — not supported |
| `mcp_mode` | ❌ Backend 400 — not supported |

### What group_by returns

The query always aggregates **`phase_end` events only**. Other event types are not aggregated.

Returned fields per group:
- `avg_duration_ms` — average phase duration
- `p95_duration_ms` — 95th percentile duration
- `success_rate_pct` — % of phase_end events with `status: "pass"`
- `total_events` — count of phase_end events in group

### filter

Confirmed working: `initiative_id`, `session_id`.
Filtering by `event` type has no effect — the query always targets `phase_end` regardless.

### Raw sample

Every query response includes a raw sample of the most recent `phase_end` events (not filtered to the group_by dimension). Shows full event envelope including `data`.

---

## Existing data in store

The store already contains events from a prior session (`session_id: "e2e-001"`, 2026-04-13) with `agent: "claude-sonnet-4-6"` — indicating e2e tests were run against the server before this exploration.

---

## Implications for design

1. **`mcp_impact` must be added to the spec.** It is server-supported and undocumented. Orchestrator should emit it at the end of each pipeline run.
2. **Proposed new events require 0008a schema changes** before they can be used. They cannot be emitted against the current server.
3. **`query_telemetry` is duration-analytics only** — it is not a general event log query. The primary use case is phase duration and success rate by agent/phase.
4. **`group_by: "mcp_mode"` is not queryable** — MCP impact analysis via `mcp_impact` events is the intended mechanism, not a query dimension.
