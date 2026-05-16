---
title: "Requirement: req-006 - TDD escalation on repeated red-green failure"
status: "active"
version: "0.1.0"
---
# Requirement: req-006 - TDD escalation on repeated red-green failure

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 1 — design risk R-003 (sub-agent coordination failure)
**Priority:** must-have

---

## Functional Requirements
- The codegen-agent TDD inner loop MUST track the number of red→green attempts per requirement.
- If a single requirement fails to reach GREEN after 3 consecutive attempts, the codegen-agent MUST escalate to the human before proceeding to the next requirement.
- The escalation message MUST identify: the requirement ID, the test file path, the nature of the failure, and the number of attempts made.
- After escalation, the pipeline MUST pause — the codegen-agent MUST NOT proceed to the next requirement without human direction.
- Subsequent requirements (beyond the blocked one) MAY resume once the human resolves the blocked requirement or explicitly instructs the agent to skip it.

## Acceptance Criteria
- [ ] `planifest-codegen-agent/SKILL.md` TDD protocol section states the 3-attempt limit per requirement.
- [ ] The escalation format is documented in the protocol (requirement ID, test path, failure description, attempt count).
- [ ] The protocol states clearly that the pipeline pauses at escalation — no silent continuation.
- [ ] A self-correction cycle count tracking mechanism is described (consistent with existing validate-agent retry pattern).

## Dependencies
- req-001 (TDD sub-loop protocol — escalation is part of the protocol)
