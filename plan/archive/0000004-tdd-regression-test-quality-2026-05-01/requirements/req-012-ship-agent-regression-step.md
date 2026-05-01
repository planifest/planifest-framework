---
title: "Requirement: req-012 - ship-agent regression confirmation step (Step R)"
status: "active"
version: "0.1.0"
---
# Requirement: req-012 - ship-agent regression confirmation step (Step R)

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 3 — ship-agent must confirm regression candidates before archiving
**Priority:** must-have

---

## Functional Requirements
- `planifest-ship-agent/SKILL.md` MUST gain a new step, designated **Step R — Regression confirmation**, inserted before the archive step.
- Step R MUST present the agent-tagged regression candidates to the human for review.
- Step R MUST require the human to explicitly confirm or reject each candidate before proceeding.
- For each confirmed candidate, the ship-agent MUST invoke `promote-to-regression.sh` with `promoted-by: "human"`.
- For each agent-auto-promoted candidate (tagged but not requiring human review per the plan), the ship-agent MUST invoke `promote-to-regression.sh` with `promoted-by: "agent"`.
- The step MUST record the human's promotion decisions in the test report artefact (see req-013).
- If no candidates are tagged, Step R MUST note "No regression candidates for this feature" and proceed.

## Acceptance Criteria
- [ ] `planifest-ship-agent/SKILL.md` contains Step R before the archive step.
- [ ] Step R documents the presentation-and-confirmation flow for human-reviewed candidates.
- [ ] Step R invokes `promote-to-regression.sh` for each confirmed promotion.
- [ ] Step R handles the empty-candidates case gracefully (no error, note in output).
- [ ] Step R is additive — no existing ship-agent steps are removed or reordered.

## Dependencies
- req-009 (promote-to-regression.sh must exist)
- req-013 (test report is where decisions are recorded)
