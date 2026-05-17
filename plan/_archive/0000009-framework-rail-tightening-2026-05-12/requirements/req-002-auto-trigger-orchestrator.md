---
title: "Requirement: REQ-002 - auto-trigger-orchestrator"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - auto-trigger-orchestrator

**Feature:** 0000009-framework-rail-tightening
**Source:** Feature brief AC — orchestrator auto-triggers at session start
**Priority:** must-have

---

## Functional Requirements

- A `UserPromptSubmit` hook is added to `.claude/settings.json` (Claude Code) that fires on every session start and invokes a script which detects whether the current directory is a planifest project (presence of `planifest-framework/`) and, if so, triggers the orchestrator skill
- The hook script is installed by `setup.sh` and `setup.ps1` as part of normal setup (no new flag required)
- A CLAUDE.md instruction is added as a fallback for tools without UserPromptSubmit hook support: "If this is a planifest project (planifest-framework/ exists), load the planifest-orchestrator skill at the start of every session"
- If `plan/current/design.md` exists, resume detection fires (existing behaviour); if not, P0 coaching begins
- The hook is idempotent — re-running setup does not add duplicate entries

## Acceptance Criteria

- [ ] `.claude/settings.json` contains a `UserPromptSubmit` hook entry pointing to the auto-trigger script after `setup.sh claude-code` or `setup.ps1 claude-code`
- [ ] The hook script checks for `planifest-framework/` before taking any action; exits 0 silently on non-planifest directories
- [ ] `CLAUDE.md` contains the fallback instruction for tools without hook support
- [ ] Re-running setup does not duplicate the hook entry (idempotent)
- [ ] Hook script installed to `.claude/hooks/enforcement/` alongside existing hooks

## Dependencies

- None
