---
title: "Requirement: REQ-006 - Write/Edit blocked when design absent or path out of scope"
summary: "gate-write.mjs blocks file writes when no confirmed design exists or the target path is outside approved component paths."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-006 - Write/Edit blocked when design absent or path out of scope

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-5, AC-6; DD-003, DD-004
**Priority:** must-have

---

## Functional Requirements

- A `PreToolUse` hook on `Write` and `Edit` tools invokes `gate-write.mjs` with the tool input.
- **Check 1 — Design existence:** If `plan/current/design.md` does not exist, exit code 2 with message: `"[Planifest] No confirmed design at plan/current/design.md. Complete Phase 0 first."` This blocks the write.
- **Check 2 — Path in scope:** If `design.md` exists, extract the component paths list. If the target file path does not match any listed component path prefix, exit code 2 with message: `"[Planifest] Path '{path}' is not covered by the confirmed design. Update design.md first."` This blocks the write.
- **Pass-through:** If `design.md` exists and the file path matches a component path, exit 0. The write proceeds unblocked.
- Path matching uses prefix comparison: a component path of `planifest-framework/hooks/` matches any file under that directory.
- The hook reads `plan/current/design.md` from the resolved project root (`cwd` from hook input).
- `gate-write.mjs` uses only Node.js built-ins (`fs`, `path`); no npm dependencies.

## Acceptance Criteria

- [ ] Attempting to Write/Edit with no `design.md` present is blocked with the design-absent message.
- [ ] Attempting to Write/Edit a path not in the component paths list is blocked with the path-not-covered message.
- [ ] Writing a file whose path matches a component path prefix proceeds unblocked.
- [ ] Exit code 2 is used for blocks (not exit code 1); message is human-readable.
- [ ] Hook exits 0 (unblocked) when `design.md` is malformed rather than crashing — falls back to pass-through.

## Dependencies

- REQ-008 (setup.sh must install this hook).
- `plan/current/design.md` component paths section must use consistent heading/list format for extraction.
- DD-004 confirmed: blocking (exit 2) is the correct behaviour, not a warning.
