---
title: "Requirement: REQ-002 - Phase end fires with duration_ms"
summary: "phase_end telemetry event is emitted by the Stop hook with a populated duration_ms field."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-002 - Phase end fires with duration_ms

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-2; DD-002
**Priority:** must-have

---

## Functional Requirements

- A `Stop` hook command is registered on each of the 7 phase skills.
- The hook command invokes `emit-phase-end.mjs <phase>` via Node.js.
- `emit-phase-end.mjs` reads a start timestamp written by `emit-phase-start.mjs` from the flag file.
- `duration_ms` is computed as `Date.now() - startTimestamp` and included in the emitted event.
- When no start timestamp is found (phase_start was never emitted), `duration_ms` is omitted and the event is emitted without it.
- The script POSTs a `phase_end` event to `${PLANIFEST_TELEMETRY_URL}/emit`.
- The script exits 0 on any error (telemetry unavailable, missing env vars, timeout).

## Acceptance Criteria

- [ ] A `phase_end` event appears in telemetry when the agent's Stop hook fires.
- [ ] The emitted event contains a `duration_ms` value > 0 when a matching phase_start was previously emitted.
- [ ] When no prior phase_start flag exists, `phase_end` is emitted without `duration_ms` (no error, no crash).
- [ ] Hook command exits within 3 seconds under all conditions.

## Dependencies

- REQ-001 (phase_start hook) — start timestamp is written by emit-phase-start.mjs.
- `structured-telemetry-mcp` server accepting POST to `/emit`.
