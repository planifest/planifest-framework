---
title: "Requirement: REQ-007 - User stories and acceptance criteria in requirement docs"
summary: "The requirement template and spec-agent skill must ensure every requirement doc captures the user story it derives from and acceptance criteria traceable to that story."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-007 - User stories and acceptance criteria in requirement docs

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** Framework quality gap — requirement docs produced by the spec-agent omit user stories; acceptance criteria cannot be traced back to the story that motivated them
**Priority:** must-have

---

## Functional Requirements
- `planifest-framework/templates/requirement.template.md` must include a `## User Story` section placed between the header block and `## Functional Requirements`
- The `## User Story` section must use the standard format: `As a [role], I [action], so that [outcome]`
- The template must make clear that one requirement doc = one user story; if a story is too large, it should be split into multiple requirement docs
- `planifest-framework/skills/planifest-spec-agent/SKILL.md` must explicitly instruct the spec-agent to:
  - Populate `## User Story` in every requirement doc it produces
  - Derive the user story directly from the confirmed design or feature brief — never invent one
  - Ensure every `## Acceptance Criteria` item is traceable to the user story in the same doc (no criteria that exist outside the story's scope)
  - If a user story is absent from the brief, flag it to the human rather than fabricating one

## Acceptance Criteria
- [ ] `requirement.template.md` contains a `## User Story` section in the template body
- [ ] The `## User Story` section appears before `## Functional Requirements` in the template
- [ ] The `## User Story` section includes the "As a / I / so that" format as a placeholder
- [ ] The `## User Story` section includes a note: one requirement doc maps to one user story
- [ ] `planifest-spec-agent/SKILL.md` contains an explicit rule requiring `## User Story` to be populated in every requirement file it produces
- [ ] `planifest-spec-agent/SKILL.md` contains a rule that acceptance criteria must be traceable to the user story in the same doc
- [ ] The spec-agent rules section states: if no user story exists for a requirement, flag to human — do not fabricate

## Dependencies
- None — this is a template and skill update only; no generated code
