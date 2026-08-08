---
title: "Domain Glossary - telemetry-hardening-and-enforcement-fixes"
summary: "Definitions of domain terms used within this feature."
status: "active"
version: "0.1.0"
---
# Domain Glossary - telemetry-hardening-and-enforcement-fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md) (updated by any agent that introduces a new domain term)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Version:** 0.28.0

## Terms

| Term | Definition | Aliases | Used In |
|------|-----------|---------|---------|
| Unified Telemetry Signal | The single `--structured-telemetry-mcp` install flag that, on its own, gates both the `.claude/telemetry-enabled` sentinel and the hook wiring in the target tool's settings, per 0000018-ADR-001 | telemetry gate | planifest-framework, setup-hook-integration |
| Network-Level Failure | A `fetch` call that rejects before any HTTP response is received (e.g. `ECONNREFUSED` surfaced as a `TypeError`), the signature of a listener gap; distinct from an HTTP error status and, unlike it, eligible for bounded retry | connection failure | planifest-framework |
| HTTP Error Status | A response the backend actually returned with a 4xx or 5xx code, meaning a listener answered and rejected the event deliberately; a real failure, never retried | HTTP error response | planifest-framework |
| Listener Gap | The brief window (observed ~1-2s) where a telemetry backend has no process bound to its port, e.g. mid-restart; produces a Network-Level Failure that is not a real, persistent emission failure | daemon restart window | planifest-framework |
| Bounded Retry | The fixed-attempt, fixed-delay retry (2 retries at 300ms gaps, ~600ms worst case) applied only to a Network-Level Failure, never to an HTTP Error Status and never turning into a queue | retry budget | planifest-framework |
| Durable Failure Marker | A JSON file under `plan/.telemetry-failures/<slug>.json`, one per distinct Root Cause Key, written by `recordTelemetryFailure()` on emission failure; git-visible, survives across sessions, never swept up by ratchet-check or archived at P7 | failure marker, marker | planifest-framework |
| Root Cause Key | The string `${hook}::${error_type}::${slugified error message}` that identifies a distinct failure for Durable Failure Marker deduplication; a repeat of the same key updates `occurrences`/`last_seen` on the existing marker rather than creating a new one | root_cause_key | planifest-framework |
| Receipt | A JSON file under `plan/.telemetry-receipts/{phase}-{event_type}-{ts}.marker`, written by `emit-event-receipt.mjs` on a successful `emit_event` call, proving the call actually happened; cross-referenced by `check-telemetry-receipts.mjs` against `build-log.md`'s `Telemetry: emitted` claims | telemetry receipt | planifest-framework |
| Emit Envelope | The fixed JSON shape every `emit_event` call and every hook-driven POST must use (`schema_version`, `event`, `product_id`, `agent`, `phase`, `tool`, `model`, `mcp_mode`, `session_id`, `timestamp`, `data`), defined in `telemetry-standards.md` | envelope | planifest-framework |
| phase_start / phase_end | The pipeline-lifecycle event pair marking a phase's beginning and completion (with `status`/`duration_ms`); owned by the orchestrator, emitted natively by hooks in this repo, never emitted by phase skills directly | phase lifecycle events | planifest-framework |
| Resolver | `resolve-phase.mjs`, which sits in front of `emit-phase-start.mjs`/`emit-phase-end.mjs`, infers the active phase from an observable hook-lifecycle signal (a `PreToolUse(Skill)` call matched via `tool_input.skill`), and re-execs the real script with the phase supplied positionally | phase resolver | planifest-framework |
| Active-Phase Marker | The file at `.claude/.planifest-active-phase`, last-write-wins, recording which phase the Resolver most recently observed starting; read by its own `end` mode to know which phase to close | | planifest-framework |
| Block-or-Proceed | The interactive question the orchestrator (marker path) or a phase skill (inline `emit_event` failure) asks the human on the loop exactly once per distinct Root Cause Key: block until resolved, or proceed without telemetry for the rest of the run | block-or-proceed question | planifest-framework |
| Human on the Loop | The person confirming decisions and receiving block-or-proceed questions and approval gates throughout a Planifest pipeline run | | planifest-framework (all components) |
| Hook Install Copy vs. Tracked Source | The distinction between `planifest-framework/hooks/` (tracked, git-recoverable, the sole source of truth) and the live registration under `.claude/` (gitignored local machine state, written by `setup.sh`'s hook-config writer, restorable only by re-running setup, not by `git checkout`) | install vs. source | planifest-framework, setup-hook-integration |
| Ratchet | The `ratchet-check.mjs` PreToolUse hook, armed only while a `plan/current/loop-state-*.md` has `status: active`, that blocks a write removing an acceptance-criteria or in-scope line from a `plan/current/` artifact unless a human-written, single-use `.ratchet-approve` line authorizes it | ratchet-check | planifest-framework |
| Live Artifact vs. Historical Record | The distinction this feature's em dash cleanup respects: files under `plan/current/`, `docs/`, and other in-flight locations are live and eligible for cleanup; `plan/_archive/` and `plan/changelog/` are historical record and are never rewritten, since editing a shipped artifact to satisfy a rule introduced afterwards would falsify the audit trail | | planifest-framework |
| Shared Module | A single `.mjs` file under `hooks/telemetry/` holding logic currently duplicated identically across hook files (`readProductId`, `recordTelemetryFailure`/marker-write, `readStdin`, phase-enum maps), imported by relative path per each hook's own header; this feature is the first shared-module extraction in this repo's hook family (backlog `0000054`, `0000057`) | shared helper module | planifest-framework |
| Closed Set (event validation) | The `KNOWN_PHASES`/`KNOWN_EVENT_TYPES` sets in `emit-event-receipt.mjs` that an incoming `phase`/`event` value must belong to before it is used to construct a receipt file path, added at P5 to close a path-traversal risk from an unvalidated agent-supplied string | | planifest-framework |
| Fail-Open | The governing rule (ADR-005) that every hook in this family exits 0 on every path, including an internal resolution or write error, so a defect degrades to a silent no-op rather than blocking the host session | never-block | planifest-framework |

No terms in this feature lacked an existing name in the source material; every term above traces to `telemetry-standards.md`, a hook's own header comment, or a named backlog entry.
