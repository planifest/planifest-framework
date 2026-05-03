---
title: "Requirement: req-008 - test suite coverage"
status: "active"
version: "0.1.0"
---
# Requirement: req-008 - test suite coverage

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** acceptance criteria
**Priority:** must-have

---

## Functional Requirements
- A test file `planifest-framework/tests/test-0000006-build-assessment.sh` MUST exist
- The test file MUST cover all 8 requirements (req-001 through req-008)
- `planifest-framework/tests/run-tests.sh` MUST be updated to include the new suite
- Tests MUST use the existing `assert.sh` helper
- Test assertions MUST cover:
  - req-001: build-log template exists; orchestrator skill references build-log creation
  - req-002: build-assessment skill file exists; frontmatter name matches; required report sections present in skill body
  - req-003: orchestrator contains P8 in prefix table and pipeline sequence; ship agent references P8
  - req-004: orchestrator contains "Model Tier" section; both tier names present; at least 8 task classifications present
  - req-005: orchestrator contains parallelism rules section; "default posture is parallel" or equivalent present
  - req-006: each of the 6 phase skills contains a parallelism directive with "MUST"
  - req-007: build-log.template.md exists; contains required sections
  - req-008: self-referential (test file existence checked by run-tests.sh inclusion)

## Acceptance Criteria
- [ ] `planifest-framework/tests/test-0000006-build-assessment.sh` exists and is executable
- [ ] Test file contains assertions for all req-001 through req-007
- [ ] `run-tests.sh` references the new suite
- [ ] All assertions pass on a clean run

## Dependencies
- req-001 through req-007 (all must be implemented before tests can pass)
