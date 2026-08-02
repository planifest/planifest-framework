---
title: "Requirement: req-001 - regression-baseline"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-001 - regression-baseline

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Source:** US-003
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As the framework maintainer, I run and record the full regression pack before touching planifest-orchestrator/SKILL.md, so that the later trim has a durable baseline to compare against, per 0000021 ADR-002's baseline-gated trim process.

## Functional Requirements
- Run the full regression pack (all tests under planifest-framework/tests/regression/) and capture a pass/fail result for each test
- Record the current word count of planifest-orchestrator/SKILL.md
- Record the current total word count across all skills/*/SKILL.md files
- Write both the test results and the word counts to a new file, plan/current/regression-baseline.md, and commit it on its own before any trim edit to SKILL.md

## Acceptance Criteria
- [ ] plan/current/regression-baseline.md exists and is committed before the first trim-related commit to SKILL.md
- [ ] It records pass/fail for all 22 regression tests
- [ ] It records the orchestrator SKILL.md word count and the total skills corpus word count as of the baseline run

## Dependencies
- None. This is the first requirement in the sequence; req-002 through req-005 depend on this one being complete first.
