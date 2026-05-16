---
title: "Requirement: req-010 - run-tests.sh regression suite integration"
status: "active"
version: "0.1.0"
---
# Requirement: req-010 - run-tests.sh regression suite integration

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 2 — regression pack must run as part of P4 CI checks
**Priority:** must-have

---

## Functional Requirements
- `planifest-framework/tests/run-tests.sh` MUST be updated to run the regression suite as a distinct, labelled block.
- The regression block MUST run after the existing feature test suites.
- The regression block header MUST be visually distinct in output (e.g. `=== Regression Suite ===`).
- If no tests exist in `tests/regression/` (empty pack), the block MUST report "No regression tests yet" and exit 0 — it MUST NOT fail.
- If any regression test fails, the overall `run-tests.sh` exit code MUST be non-zero.
- Regression test pass/fail counts MUST be included in the final summary line of `run-tests.sh`.

## Acceptance Criteria
- [ ] `planifest-framework/tests/run-tests.sh` contains a regression suite block with a labelled header.
- [ ] Running `run-tests.sh` with an empty `tests/regression/` exits 0 and reports "No regression tests yet" (or equivalent).
- [ ] Running `run-tests.sh` with a failing regression test causes overall exit non-zero.
- [ ] Final summary output includes regression pass/fail counts separately identified.
- [ ] Existing test suite blocks are unmodified — the regression block is additive.

## Dependencies
- req-007 (regression directory must exist)
- Existing `planifest-framework/tests/run-tests.sh` (retrofit to existing file)
