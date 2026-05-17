---
title: "Requirement: REQ-008 - Feature brief template user story format guidance"
summary: "The feature brief template must guide users to write proper 'As a / I / so that' user stories, not bare slugs."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-008 - Feature brief template user story format guidance

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** P0 audit — the Features table in feature-brief.template.md uses `{{story-1}}, {{story-2}}` placeholders with no format guidance; stories reach the spec-agent as bare slugs rather than properly formed "As a / I / so that" statements
**Priority:** must-have

---

## User Story
As a framework user filling in a feature brief, I want the template to show me the correct format for user stories so that the spec-agent receives well-formed, actionable stories rather than bare labels.

## Functional Requirements
- `planifest-framework/templates/feature-brief.template.md` must replace the bare `{{story-1}}, {{story-2}}` placeholders in the Features table with example user stories in "As a [role], I [action], so that [outcome]" format
- The template must include a note explaining that each user story in this table will become one requirement doc — if a story is too large, split it
- The note must be adjacent to the Features table, not buried in a separate section
- The placeholder examples must demonstrate a realistic pattern (e.g. "As a developer, I can run setup.ps1 with --include-full-skill-library, so that external skills are installed without manual copying")

## Acceptance Criteria
- [ ] `feature-brief.template.md` Features table contains at least one example row with a full "As a / I / so that" user story
- [ ] A note immediately above or below the Features table states: one user story = one requirement doc; split if a story implies more than 3 acceptance criteria
- [ ] The template contains no remaining bare `{{story-N}}` placeholders in the Features table
- [ ] The format guidance is consistent with the `## User Story` section added to `requirement.template.md` by REQ-007

## Dependencies
- REQ-007 must be complete (sets the user story format that this template must match)
