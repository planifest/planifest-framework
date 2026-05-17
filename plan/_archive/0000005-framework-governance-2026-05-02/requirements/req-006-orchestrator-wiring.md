---
title: "Requirement: REQ-006 - orchestrator-wiring"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-006 - orchestrator-wiring

**Feature:** 0000005-framework-governance
**Source:** orchestrator wiring user story (feature-brief.md)
**Priority:** should-have

---

## Functional Requirements

- planifest-orchestrator SKILL.md must surface library preferences during stack selection coaching (P0 phase)
- When the human selects or confirms a stack, the orchestrator must reference the relevant `library-standards/{language}/prefer-avoid.md` to note any strong preferences (e.g. "For TypeScript, vitest is preferred over jest; zod over joi")
- `library-standards` must be added to `bundle_standards` in orchestrator SKILL.md frontmatter

## Acceptance Criteria

- [ ] orchestrator SKILL.md references library-standards during stack coaching
- [ ] `library-standards` present in orchestrator `bundle_standards` frontmatter

## Dependencies

- REQ-001 (library-standards-doc)
