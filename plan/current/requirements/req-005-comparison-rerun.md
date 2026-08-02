---
title: "Requirement: req-005 - comparison-rerun"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-005 - comparison-rerun

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Source:** US-003
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As the framework maintainer, I want the full regression pack re-run and compared against the req-001 baseline once all trim and relocation edits have landed, so that the feature proves zero enforcement-content loss before shipping, per 0000021 ADR-002's baseline-gated trim process.

## Functional Requirements
- After req-002, req-003, and req-004 are complete, run the full regression pack (all tests under planifest-framework/tests/regression/) again
- Compare the post-trim result against plan/current/regression-baseline.md: every test that passed in the baseline must still pass now; a test updated per req-004 to check a relocated assertion is expected to pass against its new location, not the old one
- Measure the final word count of planifest-orchestrator/SKILL.md and confirm it is at or under the 8,600-word target from the feature brief's NFR (revised from 7,600 during P3; remaining size after all in-scope items landed is dense P0 operative content, not duplication or exposition - human confirmed the revised ceiling on 2026-08-02)
- Write the comparison result (pass/fail per test, before/after word counts, pass/fail against the 8,600-word target) to a committed artifact - either appended to plan/current/regression-baseline.md as a "Post-Trim Comparison" section, or a clearly-linked companion file if that reads better; the requirement implementer chooses, and records the choice
- If any regression test that passed in the baseline fails in the comparison, stop: this is a Hard Limit violation (enforcement-content loss), do not proceed to P2, and escalate to the human on the loop with the specific test and the specific content it lost

## Acceptance Criteria
- [ ] Full regression pack re-run recorded with pass/fail per test, compared against the req-001 baseline
- [ ] Zero regressions: every previously-passing test still passes (against its updated assertion location where applicable)
- [ ] Final orchestrator word count recorded and confirmed at or under 8,600 words
- [ ] Comparison result is a committed artifact, not just a report

## Dependencies
- req-001 (baseline), req-002, req-003, and req-004 must all be complete first - this is the final verification requirement in the sequence
