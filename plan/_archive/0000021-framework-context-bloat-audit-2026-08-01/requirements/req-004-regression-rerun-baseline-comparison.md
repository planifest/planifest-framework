---
title: "Requirement: req-004 - Framework Context Bloat Audit"
summary: "Re-run the regression pack after trimming and compare results against the recorded baseline."
status: "active"
version: "0.1.0"
---
# Requirement: req-004 - Framework Context Bloat Audit

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000021-framework-context-bloat-audit
**Source:** US-002
**Priority:** must-have

---

## User Story

As the human running Planifest pipelines, I want proof that the trims are safe, so that I can trust the reduced context without re-reading every diff myself.

---

## Functional Requirements
- After all per-file trims in req-003 are committed (or reverted), run the full regression pack (`planifest-framework/tests/regression/`) and the full existing suite (`run-tests.sh`) once more.
- Compare the post-trim result against the req-001 baseline: pass/fail per test, and self-correction/escalation counts for this pipeline run's own P1-P9 phases (which dogfood the trimmed orchestrator and phase skills through the remainder of this same run).
- Record the comparison and the final before/after line-count metrics (per file and in aggregate) in `plan/changelog/0000021-framework-context-bloat-audit-{date}.md`.
- If the post-trim regression run shows any new failure or a higher self-correction/escalation count than the baseline, halt and report to the human before proceeding to P4 validate — do not silently proceed.

## Acceptance Criteria
- [ ] Regression pack and `run-tests.sh` are both run once after all trims, and results are recorded
- [ ] The comparison against the req-001 baseline (pass/fail delta, self-correction/escalation delta) is written into the changelog
- [ ] Per-file and aggregate before/after line-count metrics are recorded in the changelog
- [ ] Any regression versus baseline halts the pipeline and reports to the human rather than proceeding silently

## Dependencies
- Depends on req-001 (baseline) and req-003 (all trims committed or reverted)
