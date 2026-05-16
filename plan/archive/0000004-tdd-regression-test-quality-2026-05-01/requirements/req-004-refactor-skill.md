---
title: "Requirement: req-004 - planifest-refactor skill"
status: "active"
version: "0.1.0"
---
# Requirement: req-004 - planifest-refactor skill

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 1 — refactor phase of TDD loop
**Priority:** must-have

---

## Functional Requirements
- A new skill file MUST be created at `.claude/skills/planifest-refactor/SKILL.md`.
- The skill MUST define its scope as: improve code quality while keeping all tests passing. Run the full test suite. Confirm all green.
- The skill MUST NOT add new behaviour — only improve existing code structure, readability, and quality.
- The skill MUST include a `recommended_model: haiku` frontmatter field.
- The skill MUST document the rationale for the cheaper model tier in its SKILL.md body.
- The skill MUST instruct the agent to load the declared stack capability skill when available.
- The skill MUST run the full test suite (not just the current requirement's test) and confirm all green before completing.

## Acceptance Criteria
- [ ] File `.claude/skills/planifest-refactor/SKILL.md` exists.
- [ ] Frontmatter includes `recommended_model: haiku` (or equivalent cheaper tier).
- [ ] SKILL.md body contains a rationale section for the model tier choice.
- [ ] SKILL.md explicitly states the scope boundary: no new behaviour, quality improvements only.
- [ ] SKILL.md requires running full test suite (not just the current test) before completing.
- [ ] SKILL.md requires all-green confirmation before completing.
- [ ] SKILL.md instructs loading of stack capability skill alongside this skill.

## Dependencies
- req-003 (implementer must have produced passing code before refactor runs)
