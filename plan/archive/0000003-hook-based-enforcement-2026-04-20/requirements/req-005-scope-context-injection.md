---
title: "Requirement: REQ-005 - UserPromptSubmit injects scope context"
summary: "At the start of every turn, the confirmed design scope is injected as additionalContext so the agent always has it visible."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-005 - UserPromptSubmit injects scope context

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-5; DD-003
**Priority:** must-have

---

## Functional Requirements

- A `UserPromptSubmit` hook is installed in `.claude/settings.json` that invokes `check-design.mjs`.
- `check-design.mjs` reads `plan/current/design.md` from the project root (resolved via `cwd` in the hook input).
- If `design.md` exists, the script extracts the scope section and returns it as `additionalContext` in the hook JSON response.
- The scope section is extracted as the content under the first `## Scope` or `## Component Paths` heading.
- If `design.md` does not exist, the hook returns empty `additionalContext` (no injection, no block).
- The hook exits 0 in all cases; it never blocks a turn.
- The injected context is prefixed with `[Planifest] Confirmed scope from plan/current/design.md:` so the agent can identify its source.

## Acceptance Criteria

- [ ] Starting a new turn with `design.md` present causes the scope section to appear in the agent's context.
- [ ] Starting a new turn without `design.md` present causes no injection and no error.
- [ ] The hook exits 0 under all conditions (missing file, malformed file, filesystem error).
- [ ] The injected prefix `[Planifest] Confirmed scope` is visible in the agent's context window.

## Dependencies

- `setup.sh` / `setup.ps1` must install this hook (REQ-008).
- `plan/current/design.md` must follow the standard heading structure for extraction to succeed.
