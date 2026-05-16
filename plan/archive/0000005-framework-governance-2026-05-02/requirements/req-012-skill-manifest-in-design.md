---
title: "Requirement: REQ-012 - skill-manifest-in-design"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-012 - skill-manifest-in-design

**Feature:** 0000005-framework-governance
**Source:** skill manifest in design user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- planifest-orchestrator SKILL.md must write an `## Active Skills` section in `plan/current/design.md` before P1 begins, listing all capability skills available to the plan (both plan-scoped and permanent)
- When a new skill is introduced mid-pipeline via the inbox, the orchestrator must update the `## Active Skills` section in the same turn as the skill is moved and classified
- All phase agents must read the `## Active Skills` section of `design.md` at phase start to discover available skills — they must not re-scan registries independently
- `planifest-framework/templates/execution-plan.template.md` must include an `## Active Skills` section so future plans inherit the pattern

## Acceptance Criteria

- [ ] Orchestrator writes `## Active Skills` in design.md before P1
- [ ] `## Active Skills` updated when mid-pipeline skill is added
- [ ] Phase agents read `## Active Skills` from design.md, not from registry files directly
- [ ] `execution-plan.template.md` contains `## Active Skills` section

## Dependencies

- REQ-010 (capability-skill-intake)
- REQ-011 (skill-registries)
