---
title: "Requirement: req-011 - test-report template"
status: "active"
version: "0.1.0"
---
# Requirement: req-011 - test-report template

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 3 — reviewer wants a consolidated test report at ship time
**Priority:** must-have

---

## Functional Requirements
- A template file MUST be created at `planifest-framework/templates/test-report.template.md`.
- The template MUST include placeholder sections for:
  - Feature ID and plan date
  - All tests run for this plan (sourced from P4 results), each listed with: test name, requirement ID, status (pass/fail/skipped)
  - Full regression pack state: total tests, pass count, fail count, list of failures (if any)
  - Newly promoted tests for this feature: test name, promoted-by, promotion date
  - Overall summary: total tests run, pass rate, regression health
- The template MUST use Markdown with clear section headers.
- The template MUST follow the existing template conventions in `planifest-framework/templates/`.

## Acceptance Criteria
- [ ] File `planifest-framework/templates/test-report.template.md` exists.
- [ ] Template contains all five documented sections.
- [ ] All placeholder tokens use `{{double-brace}}` notation consistent with other Planifest templates.
- [ ] Template is readable standalone — section headers describe their purpose to a human reader without context.

## Dependencies
- None (template only; no runtime dependency)
