---
title: "Requirement: req-004 - skill-boilerplate-removal"
status: "active"
version: "0.1.0"
---
# Requirement: req-004 — Remove boilerplate from skill files

**Feature:** 0000007-agent-optimisation
**Source:** Confirmed optimisation items req-001, req-003, req-005 from live optimise-agent review
**Priority:** must-have

---

## Functional Requirements

### Hard Limits removal (design req-001)

Remove the entire `## Hard Limits` section from the following skills — these 6-item blocks are identical boilerplate enforced by CLAUDE.md hooks:
- `planifest-spec-agent/SKILL.md`
- `planifest-adr-agent/SKILL.md`
- `planifest-codegen-agent/SKILL.md`
- `planifest-validate-agent/SKILL.md`
- `planifest-security-agent/SKILL.md`
- `planifest-docs-agent/SKILL.md`
- `planifest-change-agent/SKILL.md`

### Footer removal (design req-003)

Remove the `*This skill is invoked by… See [Orchestrator Skill]…*` footer line from:
- `planifest-spec-agent/SKILL.md`
- `planifest-adr-agent/SKILL.md`
- `planifest-codegen-agent/SKILL.md`
- `planifest-validate-agent/SKILL.md`
- `planifest-security-agent/SKILL.md`
- `planifest-docs-agent/SKILL.md`
- `planifest-ship-agent/SKILL.md`
- `planifest-build-assessment-agent/SKILL.md`
- `planifest-change-agent/SKILL.md`
- `planifest-test-writer/SKILL.md`
- `planifest-implementer/SKILL.md`
- `planifest-refactor/SKILL.md`

### Role Boundary removal (design req-005)

Remove the `## Role Boundary` section entirely from `planifest-security-agent/SKILL.md`.

## Acceptance Criteria

- [ ] None of the 7 target skills contain a `## Hard Limits` section
- [ ] None of the 12 target skills contain the standard footer line
- [ ] `planifest-security-agent/SKILL.md` has no `## Role Boundary` section
- [ ] All other content in all affected skills is unchanged

## Dependencies

- None — these are surgical removals with no cross-dependencies
