---
title: "Requirement: req-001 - Framework Context Bloat Audit"
summary: "Populate the regression pack and record a baseline before any audit or trim work begins."
status: "active"
version: "0.1.0"
---
# Requirement: req-001 - Framework Context Bloat Audit

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000021-framework-context-bloat-audit
**Source:** US-003
**Priority:** must-have

---

## User Story

As the human running Planifest pipelines, I want a populated regression pack covering orchestrator routing, phase sequencing, hook enforcement, and gate behavior, so that the trims in this feature can be verified safe before they ship.

---

## Functional Requirements
- Promote tests from `planifest-framework/tests/` into `planifest-framework/tests/regression/` (via `planifest-framework/scripts/promote-to-regression.sh` or equivalent) covering: orchestrator routing, phase sequencing, hook enforcement, and gate behavior. Currently only `test-0000016-pipeline-governance.sh` is promoted out of 29 candidate top-level scripts.
- The human reviews the promoted test list before it is treated as final (per design.md risk mitigation — avoid a wrong or flaky baseline).
- Run the full regression pack once, before any audit or trim file is touched, and record: pass/fail per test, and self-correction/escalation counts from this pipeline run's own build log up to that point.
- Record the baseline result in `plan/current/regression-baseline.md` (or equivalent) so it can be diffed against after trimming.

## Acceptance Criteria
- [ ] `planifest-framework/tests/regression/` contains tests asserting orchestrator routing, phase sequencing, hook enforcement, and gate behavior, beyond the single pre-existing test
- [ ] The promoted test list was reviewed by the human before the baseline run
- [ ] The regression pack has been run once and its pass/fail result plus this run's self-correction/escalation count to that point is recorded in a baseline artifact
- [ ] No file under `planifest-framework/skills/`, `standards/`, `templates/`, or root `CLAUDE.md` is audited or trimmed before this baseline artifact exists

## Dependencies
- None — this is the prerequisite requirement; req-002, req-003, and req-004 depend on this one
