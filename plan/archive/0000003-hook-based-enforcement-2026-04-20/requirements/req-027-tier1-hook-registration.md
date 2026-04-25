---
title: "Requirement: REQ-027 - Tier 1 setup scripts write adapter hook registration"
summary: "setup/cursor.sh, setup/windsurf.sh, and setup/cline.sh wire the Tier 1 adapter into the tool's hook settings file so gate-write fires automatically on Write/Edit events."
status: "done"
version: "0.1.0"
---

# Requirement: REQ-027 - Tier 1 setup scripts write adapter hook registration

**Skill:** [codegen-agent](../../planifest-framework/skills/planifest-codegen-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Post-ship gap: REQ-009 AC not fully met — adapters installed but not registered
**Priority:** must-have

## Context

REQ-009 specified that Tier 1 setup scripts install adapter scripts **and** write the hook registration to the tool's config file. The adapters were installed by `install_tier1_hooks()` correctly. However, no call to register the adapter command in the tool's settings file was made because `TOOL_SETTINGS_FILE` was absent from all three Tier 1 setup configs and no `install_tier1_hook_registration()` function existed.

Result: `gate-write.mjs` never fired for Cursor, Windsurf, or Cline sessions.

## Functional Requirements

- `setup/cursor.sh` declares `TOOL_SETTINGS_FILE=".cursor/settings.json"`.
- `setup/windsurf.sh` declares `TOOL_SETTINGS_FILE=".windsurf/settings.json"`.
- `setup/cline.sh` declares `TOOL_SETTINGS_FILE=".clinerules/hooks.json"`.
- `setup.sh` exports a new function `install_tier1_hook_registration(adapter_dest_rel, settings_rel)` that:
  - Writes idempotent `PreToolUse` hook entries for `Write` and `Edit` matchers pointing to `node <adapter_dest_rel> gate-write`.
  - Uses the same JSON hook format as `install_enforcement_hooks` for consistency.
  - Degrades gracefully if `node` is absent (prints manual instruction).
- `setup_tool()` calls `install_tier1_hook_registration` after `install_tier1_hooks` when `PLANIFEST_TIER=~1`, `TOOL_HOOK_ADAPTER_DEST`, and `TOOL_SETTINGS_FILE` are all set.
- Only `gate-write` (PreToolUse) is registered; `check-design` (UserPromptSubmit) is not registered because Tier 1 tools do not expose a UserPromptSubmit equivalent.

## Acceptance Criteria

- [x] Running `setup.sh cursor` on a fresh project creates `.cursor/settings.json` with gate-write adapter entries for Write and Edit matchers.
- [x] Running `setup.sh windsurf` creates `.windsurf/settings.json` with equivalent entries.
- [x] Running `setup.sh cline` creates `.clinerules/hooks.json` with equivalent entries.
- [x] Re-running setup does not duplicate entries (idempotent).
- [x] The command in each entry is `node .<tool>/hooks/adapters/<tool>.mjs gate-write`.

## Implementation

- `planifest-framework/setup.sh` — new `install_tier1_hook_registration()` function (lines ~299–330); new call in `setup_tool()` after `install_tier1_hooks` block.
- `planifest-framework/setup/cursor.sh` — `TOOL_SETTINGS_FILE=".cursor/settings.json"` added.
- `planifest-framework/setup/windsurf.sh` — `TOOL_SETTINGS_FILE=".windsurf/settings.json"` added.
- `planifest-framework/setup/cline.sh` — `TOOL_SETTINGS_FILE=".clinerules/hooks.json"` added.
