---
title: "Requirement: REQ-003 - Human confirmation gate before any destructive action"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-003 - Human confirmation gate before any destructive action

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-002
**Priority:** must-have

---

## User Story

As a human on the loop, I never want the skill to guess a flag that changes install behaviour, so I always see the full reconstructed flag set and confirm it before anything is deleted or re-run.

---

## Functional Requirements
- Regardless of confidence level (including all-high-confidence runs), the skill always requires an explicit human affirmative before proceeding to deletion
- The confirmation prompt shows the full flag set (with sources/confidence from REQ-002) and the exact command that will be run
- The human on the loop may reject or edit the flag set at this point; the skill does not proceed until an explicit accept

## Acceptance Criteria
- [ ] No deletion (REQ-004) or re-invocation (REQ-005) occurs before this confirmation step, in any confidence scenario
- [ ] The confirmation prompt includes the full flag list and the exact command string to be run
- [ ] The human on the loop can reject the proposed flags; on rejection, the skill halts and takes no action

## Dependencies
- REQ-002 (the flag set and confidence report must exist before it can be confirmed)
