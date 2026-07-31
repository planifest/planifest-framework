---
title: "Requirement: req-002 - hook-failure-marker"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-002 - hook-failure-marker

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000018-telemetry-emission-consistency
**Source:** US-001, US-002
**Priority:** must-have

---

## User Story

As a human running a pipeline, when telemetry emission fails or the tool is unavailable, I am told exactly what failed and asked explicitly whether to proceed without telemetry or block until it's resolved, so that the pipeline never silently chooses either path on my behalf.

---

## Functional Requirements
- `emit-phase-start.mjs`, `emit-phase-end.mjs`, and `context-pressure.mjs` write a durable failure marker recording the root cause (hook name, error type/message, timestamp) when emission fails — instead of swallowing the error with no trace
- The marker write itself follows ADR-005 (0000003, exit-zero failure mode): best-effort, never throws, the hook always exits 0 regardless of whether the marker write succeeds
- The marker is keyed/distinguishable by root cause (hook name + error type) so req-003's "once per distinct root cause per run" behavior has something concrete to check against
- The marker has a clear lifecycle: created on failure, cleared once the orchestrator has surfaced it and the human has answered (req-003) — never left indefinitely as stale state after being acknowledged

## Acceptance Criteria
- [ ] A simulated hook emission failure writes a marker file containing enough information to identify the specific root cause
- [ ] The hook itself never exits non-zero or blocks the session, regardless of whether the marker write itself succeeds or fails
- [ ] After the failure is surfaced and acknowledged (req-003), the marker is cleared and does not cause a repeat prompt for the same root cause
- [ ] A genuinely new/different root cause produces a new marker distinguishable from a prior one

## Dependencies
- None — hook-side change, independent of req-003's orchestrator-side consumption logic (though req-003 reads the format this requirement defines)
