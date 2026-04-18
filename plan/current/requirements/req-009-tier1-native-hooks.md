---
title: "Requirement: REQ-009 - Tier 1 tools enforce via native shell hooks"
summary: "Cursor, Windsurf, and Cline execute gate-write and check-design via their native hook systems."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-009 - Tier 1 tools enforce via native shell hooks

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-9; DD-005
**Priority:** must-have

---

## Functional Requirements

- **Cursor:** Adapter `hooks/adapters/cursor.mjs` translates Cursor's `PreToolUse` hook envelope to the common Planifest envelope and delegates to `gate-write.mjs` and `check-design.mjs`. Setup script `setup/cursor.sh` writes the hook registration to `.cursor/hooks.json`.
- **Windsurf:** Adapter `hooks/adapters/windsurf.mjs` (same pattern as cursor). Setup script `setup/windsurf.sh` writes to `.windsurf/hooks.json`.
- **Cline:** Adapter `hooks/adapters/cline.mjs` translates Cline's hook envelope. Setup script `setup/cline.sh` writes registration to `.clinerules/hooks.json`.
- All adapters translate the tool-specific envelope to the common envelope (`{session_id, cwd, tool_input, event}`) before invoking the shared scripts.
- All adapters use only Node.js built-ins; no npm dependencies.
- Blocking (exit code 2) from `gate-write.mjs` propagates back through the adapter to the tool's hook system as a block.

## Acceptance Criteria

- [ ] Cursor: `gate-write.mjs` fires via cursor adapter before a file Write; block message appears in Cursor UI when design absent.
- [ ] Windsurf: equivalent end-to-end as Cursor.
- [ ] Cline: equivalent end-to-end as Cursor.
- [ ] All Tier 1 setup scripts are idempotent (re-run safe).
- [ ] Adapters pass the `cwd` from the tool envelope correctly so `plan/current/design.md` is resolved from the right root.

## Dependencies

- REQ-006 (`gate-write.mjs` must exist and be executable by the adapters).
- REQ-005 (`check-design.mjs` must exist).
- DD-006 (common envelope specification).
