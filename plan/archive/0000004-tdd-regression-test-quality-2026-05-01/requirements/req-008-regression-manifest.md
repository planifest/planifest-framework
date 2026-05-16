---
title: "Requirement: req-008 - regression-manifest.json schema and tracking"
status: "active"
version: "0.1.0"
---
# Requirement: req-008 - regression-manifest.json schema and tracking

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 2 — regression pack must track promoted tests with provenance
**Priority:** must-have

---

## Functional Requirements
- A file MUST be created at `planifest-framework/tests/regression/regression-manifest.json`.
- The manifest MUST be valid JSON and MUST track each promoted test with the following fields:
  - `name` — unique identifier / filename of the test
  - `sourceFeature` — feature ID from which the test was promoted
  - `promotionDate` — ISO 8601 date of promotion (YYYY-MM-DD)
  - `promotedBy` — `"agent"` or `"human"`
  - `filePath` — relative path to the test file within `tests/regression/`
- The manifest MUST initialise as an empty array `{ "tests": [] }` when no tests have been promoted.
- The manifest MUST be the single source of truth for what is in the regression pack — no test in `tests/regression/` should be absent from the manifest, and no manifest entry should point to a missing file.

## Acceptance Criteria
- [ ] `planifest-framework/tests/regression/regression-manifest.json` exists with schema `{ "tests": [] }` on initialisation.
- [ ] The JSON schema is documented (in the manifest itself via a `$schema` comment or in an accompanying note) with all five required fields.
- [ ] `promote-to-regression.sh` (req-009) writes to this manifest — it is not manually maintained.
- [ ] The manifest format is valid JSON (parseable by `node -e "JSON.parse(require('fs').readFileSync(...))"` or equivalent).

## Dependencies
- req-007 (regression directory must exist before manifest can be placed there)
- req-009 (promotion script is what writes to the manifest)
