---
title: "Requirement: REQ-010 - Cross-session recovery from missing boot files"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-010 - Cross-session recovery from missing boot files

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-002 (cross-session continuity)
**Priority:** must-have

---

## User Story

As a human on the loop returning to a repo where a refresh was interrupted, I want the skill to recognise that state and resume from the cached flags, rather than starting a fresh detection pass or leaving me to figure out what happened.

---

## Functional Requirements
- On invocation, if `CLAUDE.md`/`AGENTS.md` are found missing and `.claude/.planifest-setup-flags` contains an uncompleted attempt (flags/command present, no corresponding successful setup completion recorded), the skill reports this recovered state to the human on the loop instead of starting fresh detection
- The skill shows the same flag-by-flag confidence report as a normal run (source: the marker file, high confidence) for a fresh confirmation, then re-runs the previously attempted command (REQ-005) once confirmed
- If `.claude/.planifest-setup-flags` is missing entirely (interruption landed before REQ-009's write, or the file was never written), the skill falls back to full detection (REQ-002), the same as a first run

## Acceptance Criteria
- [ ] Missing boot files + a marker file with an uncompleted attempt: skill reports the recovered state and re-confirms before re-running the cached command, without repeating hook-wiring inference
- [ ] Missing boot files + no marker file: skill falls back to full detection exactly as REQ-002/REQ-007 describe for a first run
- [ ] Boot files present (no interruption occurred): this recovery path is never triggered

## Dependencies
- REQ-009 (the marker file this reads must have been written by that requirement)
- REQ-002 (the fallback path when no marker exists)
