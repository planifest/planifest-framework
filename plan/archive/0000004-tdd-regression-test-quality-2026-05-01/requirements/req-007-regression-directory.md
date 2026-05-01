---
title: "Requirement: req-007 - Regression pack directory structure"
status: "active"
version: "0.1.0"
---
# Requirement: req-007 - Regression pack directory structure

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 2 — framework maintainer wants a regression pack that survives feature archives
**Priority:** must-have

---

## Functional Requirements
- A directory MUST be created at `planifest-framework/tests/regression/`.
- The directory MUST be distinct from feature-specific test directories — it is a long-term, curated collection, not a per-feature artefact.
- The directory MUST survive P7 archive operations — it MUST NOT be moved, deleted, or archived when a feature's `plan/current/` is archived.
- A `.gitkeep` or equivalent placeholder MUST ensure the directory is tracked by version control when empty.
- The regression directory MUST be documented in `planifest-framework/tests/` so its purpose is clear to future agents and humans.

## Acceptance Criteria
- [ ] Directory `planifest-framework/tests/regression/` exists.
- [ ] Directory contains a `.gitkeep` or `README.md` placeholder so it is tracked when empty.
- [ ] No feature archive operation (P7 ship-agent) removes or moves files from `tests/regression/`.
- [ ] `planifest-framework/tests/` contains documentation (inline or README) identifying `regression/` as the long-term curated suite.

## Dependencies
- None (foundational infrastructure; no upstream dependencies)
