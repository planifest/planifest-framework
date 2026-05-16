---
title: "Requirement: REQ-007 - Permitted path writes pass through unblocked"
summary: "gate-write.mjs never blocks a write that is within the confirmed design component paths."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-007 - Permitted path writes pass through unblocked

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-7
**Priority:** must-have

---

## Functional Requirements

- When `gate-write.mjs` determines the target file path falls within a listed component path, it exits 0 immediately.
- No additional checks are performed after a path match is confirmed.
- The match is case-insensitive on Windows (`path.normalize` applied to both sides before comparison).
- Relative and absolute paths are both supported: the hook resolves the target path against `cwd` before matching.
- `plan/current/` and `plan/changelog/` are always implicitly permitted (plan artefacts are never blocked by the gate).

## Acceptance Criteria

- [ ] Writing to a path listed in `design.md` component paths proceeds without block message or delay.
- [ ] Writing to `plan/current/` any file proceeds without block.
- [ ] Writing to `plan/changelog/` proceeds without block.
- [ ] Path matching works correctly on Windows (backslash normalisation).

## Dependencies

- REQ-006 (gate-write.mjs must implement the pass-through path).
