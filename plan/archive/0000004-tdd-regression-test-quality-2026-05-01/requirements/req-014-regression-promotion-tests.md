---
title: "Requirement: req-014 - Tests for regression-pack infrastructure"
status: "active"
version: "0.1.0"
---
# Requirement: req-014 - Tests for regression-pack infrastructure

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** NFR — promotion idempotency and regression run time
**Priority:** must-have

---

## Functional Requirements
- A test file MUST be created at `planifest-framework/tests/test-regression-pack.sh` covering the regression infrastructure.
- The test suite MUST include tests for:
  - `promote-to-regression.sh` — happy path: file copied, manifest updated, exit 0
  - `promote-to-regression.sh` — idempotency: running twice produces no duplicate manifest entry, exit 0
  - `promote-to-regression.sh` — missing source file: exit 1, error message
  - `regression-manifest.json` — valid JSON after promotion
  - `run-tests.sh` regression block — empty regression dir exits 0, reports no tests
  - `run-tests.sh` regression block — failing regression test causes overall exit non-zero
- The test file MUST use the existing `helpers/assert.sh` pattern consistent with other test files in `planifest-framework/tests/`.
- The test file MUST be included in `run-tests.sh` (existing invocation pattern).

## Acceptance Criteria
- [ ] `planifest-framework/tests/test-regression-pack.sh` exists and is executable.
- [ ] All six test categories above are covered.
- [ ] Tests use `helpers/assert.sh` and `print_summary` pattern.
- [ ] Test file is referenced in `run-tests.sh` (or discovered by its glob pattern).
- [ ] All tests pass (exit 0) when regression infrastructure is correctly implemented.

## Dependencies
- req-007, req-008, req-009, req-010 (all infrastructure must exist before tests can run)
