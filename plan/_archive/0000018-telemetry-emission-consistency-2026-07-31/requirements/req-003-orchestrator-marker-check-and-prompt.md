---
title: "Requirement: req-003 - orchestrator-marker-check-and-prompt"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-003 - orchestrator-marker-check-and-prompt

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000018-telemetry-emission-consistency
**Source:** US-002
**Priority:** must-have

---

## User Story

As a human running a pipeline, when telemetry emission fails or the tool is unavailable, I am told exactly what failed and asked explicitly whether to proceed without telemetry or block until it's resolved, so that the pipeline never silently chooses either path on my behalf.

---

## Functional Requirements
- At each phase-start checkpoint, `planifest-orchestrator` checks for the hook failure marker (req-002). If present and not yet acknowledged this run, it surfaces a block-or-proceed question to the human once for that root cause
- The human's answer is recorded in `plan/current/build-log.md` and honored for the rest of the pipeline run — the same root cause is never re-asked within that run
- Agent-driven emission (the phase skills' own inline `emit_event` calls for `adr_decision`, `security_finding`, `self_correction`, `deviation`, `spec_gap`, `doc_gap`, `validation_failure`, `retry_limit_exceeded`) is a separate, simpler path: on failure, the agent stops immediately, states the exact error, and asks the same block-or-proceed question inline in the same turn — no marker file needed, since this happens live in conversation
- A new, distinct failure root cause occurring later in the same run is asked about again, separately from any already-acknowledged one

## Acceptance Criteria
- [ ] A present, unacknowledged hook failure marker triggers the block-or-proceed question at the next phase-start checkpoint
- [ ] The human's answer is recorded in build-log.md and honored for the rest of the run — not re-asked for the same root cause
- [ ] An agent-driven emission failure stops the current phase skill's work immediately and asks inline, never proceeding silently
- [ ] A second, genuinely distinct failure (different root cause) during the same run triggers a fresh, separate prompt

## Dependencies
- req-002 — reads the failure marker format that requirement defines
