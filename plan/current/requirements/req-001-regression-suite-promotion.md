---
title: "Requirement: req-001 - regression-suite-promotion"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-001 - regression-suite-promotion

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Source:** US-001
**Priority:** must-have

---

## User Story

As a maintainer running the regression suite, I see all governance assertions (ratchet/product-version/consistency-check) running as first-class regression tests, so that a future change can't silently regress governance behavior without a test catching it.

---

## Functional Requirements
- Promote the governance assertions (ratchet/product-version/consistency-check) from 0000016 into the permanent regression pack via `scripts/promote-to-regression.sh` — 87 assertions (the "97" figure carried from P0 coaching was an estimate; the actual count in `test-0000016-pipeline-governance.sh` is 87, corrected at P3)
- Promoted assertions run automatically as part of the standard regression suite invocation — no separate manual step to include them

## Acceptance Criteria
- [ ] All 87 assertions execute when the regression suite is run
- [ ] Promoted assertions pass with zero false positives
- [ ] No manual step required to include them in future regression runs

## Dependencies
- None — mechanical promotion of existing, already-passing tests
