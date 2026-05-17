---
title: "Requirement: req-002 - planifest-test-writer skill"
status: "active"
version: "0.1.0"
---
# Requirement: req-002 - planifest-test-writer skill

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 1 — red phase of TDD loop
**Priority:** must-have

---

## Functional Requirements
- A new skill file MUST be created at `.claude/skills/planifest-test-writer/SKILL.md`.
- The skill MUST define its scope as: write exactly one failing test per requirement, run it, confirm exit non-zero (RED).
- The skill MUST NOT write any implementation code.
- The skill MUST include a `recommended_model: haiku` frontmatter field.
- The skill MUST document the rationale for the cheaper model tier in its SKILL.md body.
- The skill MUST instruct the agent to load the declared stack capability skill when available.
- The skill MUST output a clear RED confirmation: test file path, test name, and exit code recorded.

## Acceptance Criteria
- [ ] File `.claude/skills/planifest-test-writer/SKILL.md` exists.
- [ ] Frontmatter includes `recommended_model: haiku` (or equivalent cheaper tier).
- [ ] SKILL.md body contains a rationale section for the model tier choice.
- [ ] SKILL.md explicitly states the scope boundary: write test only, no implementation code.
- [ ] SKILL.md requires confirmation of non-zero exit (RED) before completing.
- [ ] SKILL.md instructs loading of stack capability skill alongside this skill.

## Dependencies
- None (foundational skill; no upstream skill dependencies)
