---
title: "Requirement: REQ-016 - Phase-Reversal Assessor Skill"
summary: "Fresh-context REJECT-default assessor judges defect reports — never the agent that filed them."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-016 - Phase-Reversal Assessor Skill

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-016
**Priority:** must-have
**Wave:** 1

---

## User Story

As the orchestrator receiving a defect report, I spawn a fresh-context `planifest-reversal-assessor` with a REJECT-default rubric, so that the agent claiming "the design is broken" is not the one judging that claim.

---

## Functional Requirements
- A `planifest-reversal-assessor` skill exists; invoked only as a fresh-context subagent receiving the defect report path and the referenced artifacts — never the filer's conversation
- Rubric (all must be evidenced to grant): (1) real blocker — the work genuinely cannot proceed as specified; (2) shallowest owning phase identified — the correction targets the earliest artifact that owns the defect; (3) blast radius stated — which downstream artifacts the correction invalidates; (4) budget remaining — reversal budget (2/feature) not exhausted; (5) classification — additive vs. altering, since altering voids continuous-run authorization
- Verdict artifact written to `plan/current/defect-reports/{seq}-verdict.md`: grant/deny, rubric evidence per item, correction scope, cascade list; default is DENY when evidence is unclear
- Grant/deny emits `phase_reversal_granted`/`phase_reversal_denied` (when telemetry enabled)

## Acceptance Criteria
- [ ] A seeded unfounded petition is denied (REJECT default verified)
- [ ] A seeded genuine defect is granted with all five rubric items evidenced in the verdict
- [ ] The assessor never runs in the filing agent's context (fresh subagent spawn verified)

## Dependencies
- REQ-015 (report format), REQ-011 (events), REQ-017 (executes granted verdicts)
