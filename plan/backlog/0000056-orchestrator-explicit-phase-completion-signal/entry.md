---
title: "Backlog Entry: 0000056 - orchestrator explicit phase-completion signal"
summary: "resolve-phase.mjs's phase_end fires on the first turn boundary after a phase's Skill call, not the true last turn of a multi-turn phase, so duration_ms under-reports; fixing this needs the orchestrator to explicitly signal phase completion, an orchestrator SKILL.md change out of scope for the hook-wiring requirement that surfaced it."
status: "open"
---
# Backlog Entry: 0000056 - orchestrator explicit phase-completion signal

**Source feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source phase:** P6
**Deferral source:** deliberate scope decision
**Date filed:** 2026-08-08

---

## Problem

`planifest-framework/hooks/telemetry/resolve-phase.mjs` (added by req-001/req-004) resolves `phase_end` from a `Stop` hook, which fires at the end of every response turn, not only at the true end of a pipeline phase. For a phase spanning multiple turns, this fires on the *first* turn boundary after that phase's `Skill` call was recorded, not the last one — presence of the `phase_end` event is guaranteed (the requirement's actual concern), but `duration_ms` under-reports the phase's real length. See `plan/current/recommendations.md`'s Deferred Items row (feature 0000027) for the full reasoning; `resolve-phase.mjs`'s own header comment documents this as a known limitation.

## Suggested Action

Have the orchestrator explicitly signal true phase completion (e.g. writing a distinct marker, or emitting a dedicated tool call the `Stop` hook can distinguish from an ordinary mid-phase turn boundary) so `resolve-phase.mjs` can compute accurate `duration_ms` for multi-turn phases. This is an orchestrator `SKILL.md` conduct change, not a hook-wiring change.

## Why Deferred

Out of scope for `0000027`'s req-001 (a hook-wiring requirement — presence of the event, not duration precision, was the acceptance criterion). Non-blocking: address only once a telemetry consumer (e.g. build-assessment reporting) actually needs accurate multi-turn phase duration.
