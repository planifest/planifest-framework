---
title: "Requirement: REQ-009 - Loop-Runner Skill"
summary: "Canonical loop mechanics (state, stop rules, escalation) in one skill every looping agent loads."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-009 - Loop-Runner Skill

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-009
**Priority:** must-have
**Wave:** 1

---

## User Story

As a phase agent entering any loop, I load `planifest-loop-runner` for canonical loop mechanics (state file conventions, stop rules, escalation format), so that every loop in the pipeline behaves consistently and improvements propagate everywhere at once.

---

## Functional Requirements
- A `planifest-loop-runner` skill exists at `planifest-framework/skills/planifest-loop-runner/SKILL.md` conforming to the existing skills spec grammar
- It defines: loop-state file location/schema (see REQ-010), the iteration cycle (act → observe → record → decide continue/done/escalate), stop rules (iteration cap default 3; no-progress halt when the same gap/finding survives 2 consecutive iterations), and the escalation format (full context into the state file, `Px: Blocked` style message)
- Caps are parameterized per loop: P4 validate keeps its existing 5; all other loops default to 3 unless their skill declares otherwise
- P4's validate-agent is updated to reference loop-runner for its mechanics with zero behaviour change (same cap, same halt semantics)

## Acceptance Criteria
- [ ] `planifest-loop-runner` exists and passes the skills-spec conformance conventions used by existing skills
- [ ] validate-agent references loop-runner and its observable behaviour (cap 5, halt/report) is unchanged
- [ ] Stop rules and escalation format are defined once here and nowhere else (grep: no duplicate definitions in other skills)

## Dependencies
- REQ-010 (state-file and run-log schema it prescribes)
