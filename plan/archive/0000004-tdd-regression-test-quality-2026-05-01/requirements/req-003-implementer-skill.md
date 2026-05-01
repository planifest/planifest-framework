---
title: "Requirement: req-003 - planifest-implementer skill"
status: "active"
version: "0.1.0"
---
# Requirement: req-003 - planifest-implementer skill

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 1 — green phase of TDD loop
**Priority:** must-have

---

## Functional Requirements
- A new skill file MUST be created at `.claude/skills/planifest-implementer/SKILL.md`.
- The skill MUST define its scope as: write the minimum code required to make the failing test pass, run it, confirm exit zero (GREEN).
- The skill MUST NOT over-engineer — no additional abstractions, patterns, or features beyond what makes the test pass.
- The skill MUST include a `recommended_model: haiku` frontmatter field.
- The skill MUST document the rationale for the cheaper model tier in its SKILL.md body.
- The skill MUST instruct the agent to load the declared stack capability skill when available.
- The skill MUST output a clear GREEN confirmation: test file path, test name, and exit code recorded.

## Acceptance Criteria
- [ ] File `.claude/skills/planifest-implementer/SKILL.md` exists.
- [ ] Frontmatter includes `recommended_model: haiku` (or equivalent cheaper tier).
- [ ] SKILL.md body contains a rationale section for the model tier choice.
- [ ] SKILL.md explicitly states the scope boundary: minimum passing code only, no over-engineering.
- [ ] SKILL.md requires confirmation of zero exit (GREEN) before completing.
- [ ] SKILL.md instructs loading of stack capability skill alongside this skill.

## Dependencies
- req-002 (test-writer must have produced a failing test before implementer runs)
