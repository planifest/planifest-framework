---
title: "Requirement: REQ-009 - Refresh skill writes marker before deletion"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-009 - Refresh skill writes marker before deletion

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-002 (cross-session continuity)
**Priority:** must-have

---

## User Story

As a human on the loop, if my session or the refresh process is killed between deletion and setup finishing, I want the state needed to recover to already be on disk, not lost with the process.

---

## Functional Requirements
- Immediately after REQ-003's human confirmation and before REQ-004's deletion, the skill writes the confirmed flag set and the exact command it is about to attempt into `.claude/.planifest-setup-flags`, using the same schema REQ-008 defines
- This write uses the same file as the install-time marker (REQ-008) — there is no separate cache file
- The write is synchronous and completes before the deletion step begins, so a process killed at any point after this write still has the recoverable state on disk

## Acceptance Criteria
- [ ] The marker file contains the confirmed flags and attempted command before `CLAUDE.md`/`AGENTS.md` are deleted, verified by a test that inspects the file mid-run (e.g. via a fault-injection hook)
- [ ] No separate cache file is created; `.claude/.planifest-setup-flags` is the single source for both install-time record and retry state
- [ ] A process kill immediately after this write and before deletion leaves a marker file a recovery run (REQ-010) can read

## Dependencies
- REQ-003 (confirmed flags must exist before they can be written)
- REQ-004 (this write must precede deletion)
- REQ-008 (shares the same file/schema)
