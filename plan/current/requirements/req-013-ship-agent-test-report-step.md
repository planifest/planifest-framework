---
title: "Requirement: req-013 - ship-agent test report generation step (Step T)"
status: "active"
version: "0.1.0"
---
# Requirement: req-013 - ship-agent test report generation step (Step T)

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 3 — reviewer wants a test report at ship time
**Priority:** must-have

---

## Functional Requirements
- `planifest-ship-agent/SKILL.md` MUST gain a new step, designated **Step T — Test report**, inserted after Step R and before the archive step.
- Step T MUST generate a test report artefact using the template at `planifest-framework/templates/test-report.template.md`.
- The generated report MUST be written to `plan/changelog/{feature-id}-test-report-{YYYY-MM-DD}.md`.
- The report MUST be populated with:
  - All tests run during P4 (sourced from P4 validation results)
  - Full regression pack state at the time of ship (total, pass, fail counts)
  - Newly promoted tests confirmed in Step R (highlighted section)
- The report MUST be generated before the archive step so it is included in the archived plan.

## Acceptance Criteria
- [ ] `planifest-ship-agent/SKILL.md` contains Step T after Step R.
- [ ] Step T generates the report at the correct path `plan/changelog/{feature-id}-test-report-{YYYY-MM-DD}.md`.
- [ ] The report references every test file run in P4 — no silent omissions.
- [ ] The report includes a dedicated section for newly promoted regression tests from Step R.
- [ ] The report file is committed or staged as part of the P7 artefact set before archiving.

## Dependencies
- req-011 (test-report template)
- req-012 (Step R must run first to capture promotion decisions)
- P4 results (test report content depends on validate-agent output)
