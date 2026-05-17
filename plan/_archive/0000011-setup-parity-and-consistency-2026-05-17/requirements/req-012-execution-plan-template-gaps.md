---
title: "Requirement: REQ-012 - Fix execution plan template gaps"
summary: "execution-plan.template.md has a stale skill path reference and no user story traceability section."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-012 - Fix execution plan template gaps

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** P0 audit — execution-plan.template.md line 98 references [Orchestrator Skill](../skills/orchestrator/SKILL.md) which is a stale path (correct path is planifest-orchestrator/SKILL.md); the Functional Requirements Directory section provides no structure guidance beyond "see plan/current/requirements/"
**Priority:** should-have

---

## User Story
As a spec-agent producing an execution plan, I want the template to have accurate references and clear guidance so that the artifact I produce is structurally correct without requiring me to guess or investigate broken links.

## Functional Requirements
- Line 98 of `planifest-framework/templates/execution-plan.template.md` must be updated: `[Orchestrator Skill](../skills/orchestrator/SKILL.md)` → `[Orchestrator Skill](../skills/planifest-orchestrator/SKILL.md)`
- The `## Functional Requirements Directory` section must be expanded to include:
  - A note that each requirement file covers exactly one user story
  - The naming convention: `req-{NNN}-{kebab-slug}.md`
  - A placeholder example row showing the expected file name pattern
- No other content in the template is modified

## Acceptance Criteria
- [ ] `execution-plan.template.md` line 98 references `planifest-orchestrator/SKILL.md` (not `orchestrator/SKILL.md`)
- [ ] The `## Functional Requirements Directory` section contains the naming convention `req-{NNN}-{kebab-slug}.md`
- [ ] The section contains a note: one requirement file = one user story
- [ ] No other sections are altered

## Dependencies
- None
