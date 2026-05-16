---
title: "Requirement: req-003 - P8 wired in orchestrator"
status: "active"
version: "0.1.0"
---
# Requirement: req-003 - P8 wired in orchestrator

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** "Add Phase 8 which will be Build Assessment"
**Priority:** must-have

---

## Functional Requirements
- The orchestrator skill MUST list `P8:` in its response prefix convention table with label "Build Assessment"
- The orchestrator skill MUST include P8 in the pipeline phase sequence: `P0 → P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8`
- The orchestrator skill MUST instruct: load `planifest-build-assessment-agent` skill before beginning P8
- The orchestrator skill MUST instruct: P8 is invoked after P7 archive is confirmed complete
- The ship-agent skill MUST instruct: invoke P8 after archiving, passing the archive path
- The orchestrator's Framework Index (JIT Loading) table MUST include a row for P8

## Acceptance Criteria
- [ ] Orchestrator SKILL.md contains `P8:` in the response prefix table
- [ ] Orchestrator SKILL.md pipeline sequence string includes `P8`
- [ ] Orchestrator SKILL.md Framework Index table includes a P8 row referencing `planifest-build-assessment-agent`
- [ ] Ship agent SKILL.md instructs invoking P8 after archive

## Dependencies
- req-002 (skill must exist to be referenced)
