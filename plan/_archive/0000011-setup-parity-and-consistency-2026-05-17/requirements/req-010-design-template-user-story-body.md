---
title: "Requirement: REQ-010 - Design template must capture user story text, not just count"
summary: "design.template.md records 'User stories confirmed: {count}' but not the story text. Stories are lost from context after P0 unless agents re-read the feature brief."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-010 - Design template must capture user story text, not just count

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** P0 audit — design.template.md Product Layer records a count of confirmed user stories but not the stories themselves. By P3 (codegen), the agent must re-read feature-brief.md to access stories, increasing context load and the risk of drift.
**Priority:** must-have

---

## User Story
As a framework agent working in P3 or later, I want the confirmed design to contain the full user story text so that I can implement against stories without loading the feature brief into context.

## Functional Requirements
- `planifest-framework/templates/design.template.md` Product Layer must replace `User stories confirmed: {count}` with a list of the actual user stories in "As a / I / so that" format
- Acceptance criteria count may remain as a summary field alongside the story list
- The orchestrator skill (Phase 0) must be updated to instruct the orchestrator to populate the user story list in design.md during P0 coaching — not leave it as a count
- The orchestrator Phase 0 gate checklist item "At least one user story with testable acceptance criteria exists" must be strengthened to "At least one user story in 'As a / I / so that' format is written into the design"

## Acceptance Criteria
- [ ] `design.template.md` Product Layer contains a `- User stories:` list field with "As a / I / so that" placeholder rows (not just a count)
- [ ] `planifest-orchestrator/SKILL.md` Phase 0 gate checklist requires full story text in the design, not just a count
- [ ] The current `design.md` for feature 0000011 is updated to include the full user story text (as a demonstration that the new template works)
- [ ] `Acceptance criteria confirmed: {count}` may remain as a summary; it is not removed

## Dependencies
- REQ-007 (user story format established in requirement template) must be complete first
