---
title: "Requirement: REQ-011 - Loop Telemetry and Per-Loop Toggles"
summary: "Loop iteration/reversal telemetry events plus independent per-loop enable toggles, default off."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-011 - Loop Telemetry and Per-Loop Toggles

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-011
**Priority:** must-have
**Wave:** 1

---

## User Story

As a pipeline operator, I can toggle each loop independently in project settings and see loop iteration events in the telemetry backend, so that I can judge a loop's cost against its quality gain before trusting it.

---

## Functional Requirements
- `telemetry-standards.md` gains event types `loop_iteration`, `phase_reversal_petitioned`, `phase_reversal_granted`, `phase_reversal_denied` following the existing feature-0000009 envelope (data-field snippets only)
- A per-loop toggle file convention exists (e.g. `planifest-overrides/loop-toggles.yml` or equivalent settings location decided by ADR): one key per loop (`p0_completeness`, `design_critic`, `verify_by_execution`, `cross_model_review`), values `off | report-only | on`
- Every toggle defaults `off`; zero-config behaviour is byte-identical to the pre-feature pipeline
- Emission follows the existing emission gate (tool present + `.claude/telemetry-enabled`); loop events are async and non-blocking

## Acceptance Criteria
- [ ] The four new event types are documented in telemetry-standards.md and accepted by the backend envelope
- [ ] With the toggle file absent, no loop machinery activates (verified against a reference run)
- [ ] Each loop can be enabled independently without enabling any other

## Dependencies
- REQ-009 (loops emit via loop-runner mechanics); assumption A-002 (envelope extends without redesign)
