---
title: "Build Log - 0000024-declared-product-id-for-telemetry"
summary: "Working telemetry file maintained by the orchestrator throughout the pipeline run."
---
# Build Log - 0000024-declared-product-id-for-telemetry

> Created at P0. Appended by the orchestrator at each phase boundary. Survives session changes.

## Header

| Field | Value |
|-------|-------|
| Feature ID | `0000024-declared-product-id-for-telemetry` |
| Pipeline start | `2026-08-02T22:36:54Z` |
| Tool | `claude-code` |
| Primary model | `claude-sonnet-5` |
| Cheaper model | `claude-haiku-4-5` |

---

## Phase Log

### P0 — Assess & Coach

| Field | Value |
|-------|-------|
| Start | `2026-08-02T22:36:54Z` |
| Model tier | primary |
| Skills loaded | planifest-orchestrator |
| Agents spawned | 0 |
| MCP calls | 0 |
| Parallel task batches | 0 |
| Telemetry | emitted |
| Notes | Routed via Feature Pipeline after human confirmation (Change Pipeline considered, rejected — matches precedent of prior framework-level fixes 0000021/0000022 as scoped Feature Pipeline runs). Pre-flight: on `main`, up to date with `origin/main`, confirmed by human. Branch `feat/0000024-declared-product-id-for-telemetry` created off `main`. |

Backlog pickup — CONFIRMED: reviewed all 14 open entries (0000020–0000038); none relevant to this feature's scope; leave all untouched. [source: human]

P0 exchange — scope expansion: human raised a second telemetry gap (agent-driven events not landing) mid-backlog-pickup. Investigated live: (1) confirmed via `query_telemetry` that only `phase_start`/`phase_end` have ever been recorded, only for one historical session (0000020, 01 Aug 2026) — zero agent-driven events (`adr_decision`, `security_finding`, etc.) ever recorded; (2) read `plan/_archive/0000017-.../telemetry-mcp-rca-and-fix-spec.md` — an existing RCA (26 Jul 2026) already root-caused a prior `emit_event` envelope rejection to a `structured-telemetry-mcp` tool-schema defect, handed the fix off to that repo, and left an explicit unclosed follow-up: "re-run a pipeline phase here... confirm events actually land... file this as a follow-up verification step at the next P0" — never done until now; (3) live-tested `emit_event` directly this session: first call with a flat/`event`-shaped argument failed (`expected object, received undefined` on an `envelope` field); retried with the argument wrapped under `envelope` — succeeded (`{"ok":true,"id":"f1332a6e-..."}`). Confirms the backend fix landed (real schema, arg renamed `event`→`envelope` per RCA §4.2) but this repo's own instructions were never updated to match — 100% of agent-driven calls have been failing silently on the argument shape since. [source: human decision to investigate; findings: agent-derived from live tool calls + archived RCA]

P0 exchange — CONFIRMED: fold the envelope-parameter fix into 0000024 as story 2 (same component, both small) rather than splitting into a separate feature. [source: human]

P0 exchange — ADR conflict surfaced: 0000016 ADR-002 (accepted) says single-component projects keep `component.yml` behaviour, no `product.yml`. Story 1's design (product.yml as canonical `product_id` home for all projects) extends that. CONFIRMED: extend via a new P2 ADR referencing 0000016 ADR-002, rather than storing `product_id` in `component.yml`. [source: human]

Scope Lock — happy path: product.yml declares id; every hook-driven and agent-driven event carries it as product_id, correctly shaped with the envelope argument, and lands in the backend. [source: agent-draft-accepted, confirmed via brief]

Scope Lock — first-run path: brand-new single-component project has no product.yml; P0 step 3b detects this, asks the human, creates a minimal product.yml with just id. [source: agent-draft-accepted, confirmed via brief]

Scope Lock — error/sad path (revised): human rejected the initial fallback-based draft, then explicitly directed removal of `getProductId()`'s git-path fallback entirely — "remove the function... fail and ask the human." Reconciled against ADR-005 (hooks must never block): hooks never emit a path-shaped product_id — an unresolvable product_id is routed through the existing `recordTelemetryFailure()` marker mechanism, no new marker format, never blocking. The orchestrator's P0 step 3b (interactive, not a hook) hard-stops and asks before proceeding. [source: human, mid-course correction]

Scope Lock — cross-session continuity: if P0 is interrupted after the human answers but before product.yml is written, next session's resume detection re-reads, finds it still absent, re-prompts — no partial-write state to recover. [source: agent-draft-accepted, confirmed via brief]

Scope Lock complete. All four scenario paths captured; feature-brief.md updated to reflect the error-path revision (no fallback function, failure-marker routing instead).

---

### P1 — Requirements

| Field | Value |
|-------|-------|
| Start | `2026-08-03T00:24:00Z` |
| Model tier | primary |
| Skills loaded | planifest-spec-agent |
| Agents spawned | `{{count}}` |
| MCP calls | `{{count}}` |
| Parallel task batches | `{{count}}` |
| Telemetry | emitted |
| Notes | Continuous run confirmed; human reinforced subagent-decomposition preference. 2 independent user stories (US-001, US-002) — candidate for parallel dispatch per Agent Dispatch Standards. |

---

## Summary (filled at P7)

| Metric | Value |
|--------|-------|
| Total phases completed | `{{count}}` |
| Total agents spawned | `{{count}}` |
| Total MCP calls | `{{count}}` |
| Phases using parallelism | `{{count}}` |
| Primary tier agent calls | `{{count}}` |
| Cheaper tier agent calls | `{{count}}` |
| Self-corrections | `{{count}}` |
| Phases skipped | `{{list or "none"}}` |
| Phases with a recorded telemetry gap | `{{count — phases where Telemetry was failed-with-recorded-choice, or "0"}}` |
