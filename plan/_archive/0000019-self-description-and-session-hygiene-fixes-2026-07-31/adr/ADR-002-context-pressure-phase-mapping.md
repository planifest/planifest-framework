---
title: "ADR 002: context_pressure telemetry events map to phase: \"orchestrator\""
summary: "The 0000027 hook fix maps context-pressure's envelope phase field to the existing \"orchestrator\" enum value rather than adding a new enum member or reusing a different existing value."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - context_pressure telemetry events map to phase: "orchestrator"

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Tool:** Claude Code
**Model:** claude-sonnet-5
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Component:** N/A — telemetry hook (`planifest-framework/hooks/telemetry/context-pressure.mjs`), not a `src/{component-id}`
**Status:** accepted
**Date:** 2026-07-31

---

## Context

During P0 of this feature, a telemetry failure marker led to discovering that `context-pressure.mjs` sent `phase: "monitoring"` on every emission — a value that is not a member of the telemetry backend's `phase` enum (`orchestrator | spec | adr | codegen | validate | security | docs | change | ship`). Every emission from this hook failed with HTTP 400, unconditionally, in any environment — confirmed by reproducing the failure live in this session and by a direct POST to the backend that changed status from 400 to 200 purely by changing the `phase` value.

The hook needed to send a value that is actually a member of the enum. `context_pressure` is a session-wide monitoring check that doesn't correspond to any single P1–P9 pipeline phase — it can fire while any phase is active, or between phases. The question was which existing enum value best represents that.

## Decision

Map `context_pressure` events to `phase: "orchestrator"`.

This is not merely "pick any legal value to stop the 400" — it's the semantically closest fit available in the current enum. Context-window monitoring and the decision to clear or compact it is explicitly framed as an orchestrator responsibility elsewhere in this same feature: req-007 (0000012) adds Phase-0-start and P9-completion `/clear` triggers plus dynamic compaction monitoring, all as orchestrator-owned behaviour. `context-pressure.mjs` is the sensor for exactly that responsibility, so attributing its events to the orchestrator phase is consistent with how the framework already assigns ownership of context hygiene.

The alternative of adding a new `"monitoring"` (or similar) enum value to the telemetry backend's schema was considered and rejected for this fix — see Alternatives.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Add `"monitoring"` as a new legal `phase` enum value in the telemetry backend | Most semantically precise — a dedicated value for a genuinely cross-cutting event type | The telemetry backend (`telemetry-mcp`) lives in a separate sibling repository outside this framework's source; this feature's scope is the framework repository, not that backend. Widening a shared schema is also a bigger, more consequential change than a one-line hook fix deserves | Rejected — out of scope for this repository; filed as a follow-up consideration rather than done here |
| Use `phase: "ship"` (the phase active during P9, the other explicit `/clear` trigger point in req-007) | Reuses an existing value without over-claiming orchestrator ownership | `context_pressure` fires throughout a session, not only during P9 — mapping it to "ship" would misattribute events that occur during P1-P6 phases | Rejected — doesn't match when the hook actually fires |
| Leave `phase: null` or omit the field | Avoids picking a possibly-wrong value | `phase` is a required field in the envelope schema (`must have required property`, confirmed by the validation error observed before the fix); omitting it doesn't validate either | Rejected — not schema-legal |

## Affected Components

| Component | Impact |
|-----------|--------|
| N/A (telemetry hook) | `planifest-framework/hooks/telemetry/context-pressure.mjs` — one-line change to the emitted envelope's `phase` field |

## Consequences

**Positive:**
- `context_pressure` emissions now succeed (verified: HTTP 400 → 200 against the running backend) instead of failing unconditionally on every occurrence.
- The mapping is consistent with req-007's framing of context hygiene as an orchestrator responsibility, rather than an arbitrary schema-legal placeholder.

**Negative:**
- A future telemetry consumer querying "orchestrator phase" events will see `context_pressure` events mixed in with actual P0 orchestrator-phase activity, which could skew per-phase analysis if not filtered by `event` type as well as `phase`.

**Risks:**
- If a future maintainer judges this semantic mapping wrong and wants a dedicated `phase` value instead, that requires a schema change in the separate `telemetry-mcp` repository — out of this repository's control and not a low-cost follow-up. Logged as R-005 in `plan/current/risk-register.md` (accepted, low likelihood/impact).

---

## Related ADRs

- None yet recorded for this feature area. Conceptually related to req-007 (0000012)'s orchestrator-context-ownership framing, though that requirement has no ADR of its own (it's a documented behavioural addition, not judged to cross the ADR threshold on its own).

---

## Supersedes

- None.

## Superseded By

- None.

---

*Generated by adr-agent. Path: `plan/current/adr/ADR-002-context-pressure-phase-mapping.md`*
