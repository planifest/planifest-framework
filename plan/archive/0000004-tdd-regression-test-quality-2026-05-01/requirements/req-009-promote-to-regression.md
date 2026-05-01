---
title: "Requirement: req-009 - promote-to-regression.sh idempotent promotion script"
status: "active"
version: "0.1.0"
---
# Requirement: req-009 - promote-to-regression.sh idempotent promotion script

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 2 — curated regression pack with tooling for promotion
**Priority:** must-have

---

## Functional Requirements
- A bash script MUST be created at `planifest-framework/scripts/promote-to-regression.sh`.
- The script MUST accept the following arguments: `<test-file-path> <source-feature-id> <promoted-by>`.
- The script MUST copy the test file to `planifest-framework/tests/regression/`.
- The script MUST update `regression-manifest.json` with the new entry (name, sourceFeature, promotionDate, promotedBy, filePath).
- The script MUST be idempotent: running it twice with the same test file MUST NOT create duplicate entries in the manifest or duplicate files in `tests/regression/`.
- The script MUST exit non-zero with a clear error if the source test file does not exist.
- The script MUST exit non-zero with a clear error if `regression-manifest.json` cannot be written.
- The script MUST be executable (`chmod +x` or equivalent).

## Acceptance Criteria
- [ ] `planifest-framework/scripts/promote-to-regression.sh` exists and is executable.
- [ ] Running the script with a valid test file copies it to `tests/regression/` and updates the manifest.
- [ ] Running the script twice with the same file produces identical manifest state (no duplicates).
- [ ] Running the script with a nonexistent file exits 1 with an error message.
- [ ] The `promotionDate` field in the manifest entry matches the date the script was run (ISO 8601 YYYY-MM-DD).
- [ ] Script is covered by a test in `planifest-framework/tests/` (see req-014).

## Dependencies
- req-007 (regression directory)
- req-008 (regression-manifest.json schema)
