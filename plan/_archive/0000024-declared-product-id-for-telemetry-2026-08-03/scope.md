---
title: "Scope - 0000024-declared-product-id-for-telemetry"
summary: "Defines explicit boundaries of what is in scope and out of scope."
status: "draft"
version: "0.1.0"
---
# Scope - 0000024-declared-product-id-for-telemetry

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md)
**Feature:** 0000024-declared-product-id-for-telemetry
**Version:** 0.24.0

## In Scope

- Deleting `getProductId(cwd)` and its `git rev-parse --show-toplevel` fallback entirely from all 3 telemetry hooks (`emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs`)
- Sourcing `product_id` from `product.yml`'s `id` field only, with no fallback value — unresolvable `product_id` routes through each hook's existing `recordTelemetryFailure()` marker mechanism, never blocking (ADR-005)
- Extending `planifest-orchestrator/SKILL.md` P0 step 3b to hard-stop and prompt the human for a declared product id when `product.yml`/`id` is absent, creating a minimal `product.yml` for single-component projects if none exists
- A new P2 ADR extending 0000016 ADR-002 to cover `product.yml`'s new role for single-component projects
- Correcting `telemetry-standards.md`'s Event Envelope documentation to name `envelope` (not `event`) as the `emit_event` MCP tool's top-level argument, with a corrected usage example
- Auditing all 8 phase skills' `## Telemetry` sections for the same stale-argument gap, fixing any found
- Live re-verification: emitting at least one real agent-driven event (e.g. `adr_decision`) during this feature's own P2/P4 and confirming it lands via `query_telemetry`
- Regression tests covering all 4 hook outcomes (declared id, absent file, malformed YAML, missing id field) — none asserting a path-shaped fallback value

## Out of Scope

- Any change inside the `structured-telemetry-mcp` repo itself — its `emit_event` fix already shipped there; this feature only corrects this repo's stale knowledge of it
- Root Cause B from the 0000017 RCA (missing `loop_iteration`/`phase_reversal_*` schema entries in the deployed backend schema) — if live re-verification finds this still broken, file a fresh backlog entry rather than fix it here
- New telemetry event types, schema changes, or backend/query changes
- Backfilling historical telemetry data that was lost to the envelope-argument bug before this fix
- Any change to `component.yml`-based single-component behaviour beyond what's needed for the `product.yml` `id`-declaration extension

## Deferred

Nothing deferred — Scope Lock Challenge complete, no deferred items surfaced during P0 coaching.
