---
title: "Requirement: REQ-004 - phase-commit-directives"
summary: "Orchestrator commits plan/current/ at each phase gate rather than waiting until P7."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-004 - phase-commit-directives

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-004
**Priority:** must-have

---

## User Story

As a pipeline agent, I commit plan/current/ at each phase gate, so that design evolution is preserved in git history incrementally rather than only at P7.

---

## Functional Requirements
- `planifest-framework/skills/planifest-orchestrator/SKILL.md` contains an explicit commit step at the gate of each phase: P0, P1, P2, P3, P4, P5, P6
- Commit step instructs the orchestrator to stage and commit all new or modified files under `plan/current/` using the convention `plan(p{N}): {artifact summary}`
- `planifest-framework/pipeline-reference.md` and `project-operations.md` document that plan/ should be committed throughout the pipeline run, not only at P7

## Acceptance Criteria
- [ ] planifest-orchestrator/SKILL.md has a commit step at P0, P1, P2, P3, P4, P5, and P6 gates
- [ ] Commit convention `plan(pN): ...` is stated in the SKILL.md commit step
- [ ] pipeline-reference.md "When to commit plan/" section present and accurate
- [ ] project-operations.md plan/ row states "commit throughout the pipeline run"

## Dependencies
- None

> **Status: IMPLEMENTED** — delivered via patches 002 and 003 (commits 81b3860, 70db52e).
