---
title: "Requirement: REQ-008 - Enforcement hooks installed unconditionally by setup scripts"
summary: "setup.sh and setup.ps1 install gate-write and check-design hooks on every run, regardless of MCP configuration."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-008 - Enforcement hooks installed unconditionally by setup scripts

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-8
**Priority:** must-have

---

## Functional Requirements

- `setup.sh` and `setup.ps1` are updated to unconditionally write the `UserPromptSubmit` (`check-design.mjs`) and `PreToolUse` Write/Edit (`gate-write.mjs`) hook entries into `.claude/settings.json`.
- Installation is idempotent: re-running setup on a project that already has the hooks does not duplicate entries.
- Installation does not check for MCP flags — enforcement applies to all Planifest-enabled projects.
- If `.claude/settings.json` does not exist, setup creates it with the minimum required structure.
- If `.claude/settings.json` exists and has existing hook entries, the new entries are merged (not replaced).
- Setup scripts confirm success with a printed message: `[Planifest] Enforcement hooks installed.`

## Acceptance Criteria

- [ ] Running `setup.sh` on a fresh project creates `.claude/settings.json` with both hook entries.
- [ ] Running `setup.sh` twice on the same project produces no duplicate hook entries.
- [ ] The hooks are present regardless of whether `PLANIFEST_TELEMETRY_URL` is configured.
- [ ] `setup.ps1` achieves equivalent results on Windows.
- [ ] Existing `.claude/settings.json` content is preserved when hooks are added.

## Dependencies

- REQ-005 (`check-design.mjs` must exist before setup installs it).
- REQ-006 (`gate-write.mjs` must exist before setup installs it).
