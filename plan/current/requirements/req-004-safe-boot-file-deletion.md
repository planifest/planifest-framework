---
title: "Requirement: REQ-004 - Safe boot-file deletion"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-004 - Safe boot-file deletion

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-002
**Priority:** must-have

---

## User Story

As a human on the loop, I can have the skill delete only the boot files `setup.sh`/`setup.ps1` won't overwrite on their own (`CLAUDE.md`, `AGENTS.md`), so that templates actually regenerate without touching `settings.local.json` or any other file I own.

---

## Functional Requirements
- The deletion allowlist is hardcoded to exactly `CLAUDE.md` and `AGENTS.md` (whichever exist in the repo), no other file is ever a candidate for deletion by this skill
- `settings.local.json`, `.claude/settings.local.json`, and any other user-owned or tool-local file are never touched by this skill under any circumstance
- Deletion only happens after REQ-003's confirmation, immediately before the setup script is re-invoked (REQ-005)
- Before deleting, the skill writes the confirmed flags and the exact command it is about to run to `.claude/.planifest-setup-flags` (see REQ-009) so the action is recoverable if interrupted

## Acceptance Criteria
- [ ] Only `CLAUDE.md` and `AGENTS.md` are ever deleted by this skill; the allowlist is not configurable or extensible at runtime
- [ ] `settings.local.json` and other user-owned files are verifiably untouched by a refresh run (test asserts file mtimes/contents unchanged)
- [ ] Deletion never occurs before REQ-003's human confirmation
- [ ] The marker-file write (REQ-009) happens before deletion, not after

## Dependencies
- REQ-003 (confirmation must precede deletion)
- REQ-009 (marker write must precede deletion, for cross-session recovery)
