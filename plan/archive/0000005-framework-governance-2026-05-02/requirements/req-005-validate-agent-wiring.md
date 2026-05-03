---
title: "Requirement: REQ-005 - validate-agent-wiring"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-005 - validate-agent-wiring

**Feature:** 0000005-framework-governance
**Source:** validate-agent wiring user story (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- planifest-validate-agent SKILL.md must add a library-audit step to its CI loop (alongside lint/typecheck/test/build)
- The library-audit step scans the installed dependency manifest for the component's declared stack and checks every dependency against the avoid list in `library-standards/{language}/prefer-avoid.md`
- On finding an avoided library the validate-agent must: fail the CI loop, name the avoided library, and name its preferred alternative
- The step must be skipped if no `prefer-avoid.md` exists for the component's declared language (e.g. unpopulated stub) — a missing standard is not a CI failure
- `library-standards` must be added to `bundle_standards` in validate-agent SKILL.md frontmatter

## Acceptance Criteria

- [ ] validate-agent SKILL.md contains library-audit CI step
- [ ] `library-standards` present in validate-agent `bundle_standards` frontmatter
- [ ] Validate-agent fails with library name and preferred alternative on avoid-list match
- [ ] Validate-agent skips audit gracefully when language stub has no content

## Dependencies

- REQ-001 (library-standards-doc)
