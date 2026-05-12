---
title: "Requirement: REQ-001 - skips-path-fix"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-001 - skips-path-fix

**Feature:** 0000009-framework-rail-tightening
**Source:** Feature brief AC — `.skips` path must be `plan/current/.skips` consistently
**Priority:** must-have

---

## Functional Requirements

- All references to `.skips` in `planifest-framework/skills/planifest-orchestrator/SKILL.md` must be qualified as `plan/current/.skips`
- No bare `.skips` reference (i.e. not preceded by `plan/current/`) must remain in the file
- The fix applies to the source file; setup.ps1/setup.sh propagate it to tool skill dirs on re-run

## Acceptance Criteria

- [ ] `grep -n '\b\.skips\b' planifest-framework/skills/planifest-orchestrator/SKILL.md` returns only lines where `.skips` is preceded by `plan/current/`
- [ ] All three previously bare references are updated
- [ ] Ship-agent phase instructions in SKILL.md reference `plan/current/.skips` for read, write, and delete operations

## Dependencies

- None
