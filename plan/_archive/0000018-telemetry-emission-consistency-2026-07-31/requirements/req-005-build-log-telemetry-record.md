---
title: "Requirement: req-005 - build-log-telemetry-record"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-005 - build-log-telemetry-record

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000018-telemetry-emission-consistency
**Source:** US-001
**Priority:** must-have

---

## User Story

As a human running a Planifest pipeline with telemetry enabled, I see every event the phase skills specify actually emitted during the run, so that the collected data reflects real pipeline behavior, not whatever an agent happened to remember.

---

## Functional Requirements
- Each phase's `build-log.md` entry includes a telemetry-activity field recording one of: emitted successfully / failed-with-recorded-choice / confirmed-disabled for that phase
- Update `build-log.template.md`'s per-phase block template (and the orchestrator's phase-block-writing instructions) to include this field
- This creates a self-auditing trail so a human, or the build-assessment-agent at P8, can verify telemetry compliance for any archived feature after the fact

## Acceptance Criteria
- [ ] `build-log.template.md`'s phase block template includes a Telemetry field
- [ ] A human or the build-assessment-agent reading any archived build-log can see per-phase telemetry activity with no unexplained gaps
- [ ] The field's three possible states (emitted / failed-with-recorded-choice / confirmed-disabled) cover every real outcome — no phase can complete without one of these being recorded

## Dependencies
- req-003 — "failed-with-recorded-choice" state depends on the interactive protocol that produces a recorded choice
