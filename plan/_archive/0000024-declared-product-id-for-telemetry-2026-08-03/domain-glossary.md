---
title: "Domain Glossary - 0000024-declared-product-id-for-telemetry"
summary: "Definitions of domain terms used within this feature."
status: "draft"
version: "0.1.0"
---
# Domain Glossary - 0000024-declared-product-id-for-telemetry

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md) (updated by any agent that introduces a new domain term)
**Feature:** 0000024-declared-product-id-for-telemetry
**Version:** 0.24.0

## Terms

| Term | Definition | Aliases | Used In |
|------|-----------|---------|---------|
| Declared product id | The human-confirmed value stored in `product.yml`'s `id` field, used as the sole source of `product_id` on every telemetry event. Replaces the previous path-derived value entirely — there is no fallback. | product id, `id` field | planifest-framework (hooks, orchestrator) |
| product_id | The telemetry envelope field attributing an event to a specific product/repo, so events from multiple projects sharing one backend are distinguishable. Now always sourced from the declared product id, never a filesystem path. | — | telemetry-standards.md, all 3 hooks |
| Emission failure | The condition where a telemetry hook cannot resolve a required value (e.g. `product_id`) and cannot successfully POST an event. Routed through the existing `recordTelemetryFailure()` marker mechanism; never blocks the session (ADR-005). | — | emit-phase-start.mjs, emit-phase-end.mjs, context-pressure.mjs |
| Failure marker | A JSON file under `plan/.telemetry-failures/` recording a hook's emission failure root cause, written by `recordTelemetryFailure()`. Pre-existing mechanism (0000018) reused as-is by this feature — no new marker format introduced. | — | plan/.telemetry-failures/ |
| Envelope (MCP argument) | The `emit_event` MCP tool's top-level call argument, named `envelope` in the current deployed `structured-telemetry-mcp` schema. Not to be confused with the envelope's own internal `event` discriminator field — the name collision is the exact source of req-002's bug. | tool argument | telemetry-standards.md, all 8 phase skills' Telemetry sections |
| Event (envelope field) | The internal discriminator field inside the envelope object (e.g. `"event": "phase_start"`) naming which of the 14+ telemetry event types this instance is. Distinct from the MCP tool's `envelope` argument name — see above. | event type, event name | telemetry-standards.md |
| Hard-stop (P0 prompt) | The orchestrator's interactive behaviour when `product.yml`/`id` is absent or malformed: it stops Phase 0 Start Actions step 3b and asks the human before proceeding, rather than silently falling back or continuing. Distinct from hook-driven failure handling, which cannot be interactive. | — | planifest-orchestrator/SKILL.md |
