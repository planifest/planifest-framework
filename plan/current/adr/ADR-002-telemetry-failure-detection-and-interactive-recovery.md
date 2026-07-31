---
title: "ADR 002: Telemetry Failure Detection and Interactive Recovery"
summary: "Hook-driven emission stays fire-and-forget (ADR-005 unchanged) but now writes a durable failure marker on error, checked by the orchestrator at phase-start checkpoints; agent-driven emission stops and asks immediately inline. Either path: the human is asked once per distinct root cause per run and that answer is honored for the rest of the run."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - Telemetry Failure Detection and Interactive Recovery

**Skill:** [adr-agent](../../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** claude-code
**Model:** claude-sonnet-5
**Feature:** 0000018-telemetry-emission-consistency
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-07-31

---

## Context

Telemetry emission currently fails in two structurally different ways with no consistent human-facing response. Hook-driven emission (`phase_start`/`phase_end`/`context_pressure`, fired automatically per ADR-005's exit-zero convention, 0000003) swallows failures completely silently. Agent-driven emission (`emit_event` calls made inline by phase skills for `adr_decision`, `security_finding`, etc.) is instructed to "skip silently if unavailable" with no enforcement. This session's own 0000017 pipeline run demonstrated the consequence directly: zero telemetry events were emitted across an entire P0-P9 run, and nothing surfaced that fact to the human.

---

## Decision

Two different mechanisms for two structurally different emission paths, unified by a shared human-facing outcome. Hook-driven emission remains fire-and-forget and exit-zero (ADR-005, 0000003, unchanged — hooks must never block or throw), but now writes a durable failure marker on error instead of swallowing it; the orchestrator checks this marker at each phase-start checkpoint and surfaces an interactive block-or-proceed question to the human. Agent-driven emission, which happens live in conversation, stops immediately on failure, states the exact error, and asks the same block-or-proceed question inline — no marker needed since the agent is already present to ask.

Either path: the human is asked once per distinct failure root cause per pipeline run (not once per every underlying attempt, which could be dozens for hook-driven failures given hooks fire on every Write/Edit), and that answer is recorded in `build-log.md` and honored for the rest of the run.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Make hooks interactive too (block and prompt directly) | Single unified mechanism, no marker-file indirection needed | Violates ADR-005 (0000003) — hooks are deliberately non-interactive and must never block the session on a hook bug; a load-bearing safety property | Rejected — would break an established, deliberate architectural boundary |
| Leave hook-driven failures silent, only fix agent-driven emission | Smaller change | Doesn't address hook-driven phase_start/phase_end failures — exactly the failure mode that caused 0000017's telemetry loss | Rejected — doesn't solve the actual problem that motivated this feature |
| Durable failure marker (hook-side) + orchestrator-side interactive surfacing, agent-driven stays immediate-inline (this decision) | Respects ADR-005's hook boundary; still gets the human an explicit choice for every failure type, just with a one-checkpoint lag for hook-driven failures instead of instant | Adds a small new artifact (the marker file) and a new orchestrator-side check step | Chosen — the only option that closes the actual gap without violating an established safety boundary |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `planifest-framework/hooks/telemetry/{emit-phase-start,emit-phase-end,context-pressure}.mjs` | On emission failure, write a durable failure marker (root cause identity) instead of swallowing the error; marker write itself stays best-effort/exit-zero per ADR-005 |
| `planifest-framework/skills/planifest-orchestrator/SKILL.md` | New marker-check step at each phase-start checkpoint; interactive block-or-proceed prompt; records human's answer in build-log.md, honored for rest of run |
| All 8 phase skills' Telemetry sections | Agent-driven emission failure rewritten to stop immediately, state exact error, ask inline — replacing "skip silently if unavailable" |

---

## Consequences

**Positive:**
- Closes both failure paths (hook-driven and agent-driven) with mechanisms appropriate to each
- Preserves ADR-005's hook safety boundary rather than compromising it
- Every failure results in an explicit, recorded human decision rather than a silent default

**Negative:**
- Hook-driven failures have a small detection lag (surfaced at the next phase-start checkpoint, not the instant the hook fails) — an acceptable trade-off for preserving hook non-interactivity, but a real, small gap compared to true real-time detection

**Risks:**
- The failure marker itself could fail to write (disk full, permissions), and its absence after a known-attempted emission could be misread as success (risk-register R-001). This ADR does not fully close that residual gap; req-003's implementation must explicitly account for it or document why it can't be fully closed.

---

## Related ADRs

- ADR-005 (0000003) exit-zero failure mode - extends, preserves

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent.*
