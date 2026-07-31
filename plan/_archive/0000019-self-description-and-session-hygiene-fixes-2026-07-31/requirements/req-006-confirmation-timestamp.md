---
title: "Requirement: req-006 - timestamped design confirmation"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-006 - timestamped design confirmation

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-003 (backlog 0000011)
**Priority:** should-have

---

## User Story

As a human running a pipeline session, I want design confirmations to carry a local timestamp and timezone, so that multiple version iterations confirmed on the same day are disambiguated.

---

## Functional Requirements
- Update the `## Confirmation` section format in `planifest-framework/templates/design.template.md` and the orchestrator's corresponding instructions (`.claude/skills/planifest-orchestrator/SKILL.md`, "What you produce at the end of Phase 0") to include a local timestamp and timezone.
- Format: `Human confirmed this design before proceeding: yes // Date and Time confirmed: {DD MMM YYYY} @ {HH:MM AM/PM} {timezone abbreviation}` — confirmation status and timestamp separated by `//`.
- This format was already dogfooded in this feature's own `plan/current/design.md` during P0 (see Confirmation section) — this requirement is what makes that the documented convention rather than a one-off.

## Acceptance Criteria
- [ ] `design.template.md`'s Confirmation section shows the `//`-delimited timestamp format.
- [ ] Orchestrator SKILL.md's Phase 0 instructions for writing the Confirmation section match the template.
- [ ] Format includes date, local time, and timezone abbreviation.

## Dependencies
- None.
