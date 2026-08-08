---
title: "Requirement: req-002 - Fix cline.sh/cline.ps1 path collision"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-002 - Fix cline.sh/cline.ps1 path collision

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-002 (backlog 0000034)
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As a downstream adopter running setup.sh for Cline, I want the boot-file and skills-dir paths in cline.sh/cline.ps1 to stop colliding, so that `setup.sh cline` and `setup.sh all` complete successfully on a fresh workspace.

## Grounding (current repo state)

- `planifest-framework/setup/cline.sh` sets `TOOL_SKILLS_DIR=".clinerules/skills"` and `TOOL_BOOT_FILE=".clinerules"`. `planifest-framework/setup/cline.ps1` sets the equivalent `SkillsDir = '.clinerules\skills'` and `BootFile = '.clinerules'`.
- In `setup.sh`'s `setup_tool()`, `copy_skills "$skills_dir"` runs first (line ~1063), and `copy_skills()` does `mkdir -p "$dest_dir"` for each skill under `$target_dir/$skill_name` — i.e. `.clinerules/skills/{skill-name}/` — which forces `.clinerules` to exist as a **directory** on disk before the boot-file step ever runs.
- `write_boot_file()` (line ~157) is called afterward with `TOOL_BOOT_FILE` (`.clinerules`) as the target path. It does `mkdir -p "$(dirname "$path")"` (a no-op here, since `dirname ".clinerules"` is `.`), then checks `[ ! -f "$path" ]` and, if true, runs `echo "$content" > "$path"`. Because `.clinerules` already exists as a directory (not a regular file), `[ -f ".clinerules" ]` is false, so the script attempts `echo "$content" > ".clinerules"` — which fails with a shell "Is a directory" error. `setup.sh` runs under `set -euo pipefail`, so this aborts the entire `setup.sh cline` (or `setup.sh all`) invocation non-zero.
- This exact failure mode and mechanism is already documented, independently, in this repo's own `planifest-framework/tests/test-0000023-req-003-copilot-setup-self-copy.sh` (part (e), lines ~109-122): that test explicitly calls out `setup/cline.sh`'s `.clinerules` directory/file collision as a known, separate, pre-existing bug blocking `setup.sh all` from reaching exit 0, and asserts around it rather than fixing it (out of scope for that requirement). This requirement is the fix that test's comment defers to.
- Researched Cline's actual expected layout: Cline (since v3.7) natively supports `.clinerules/` as a **directory** containing multiple `.md`/`.txt` rule files, all automatically concatenated into the system prompt — this is a first-class, documented Cline feature (see `docs.cline.bot/customization/cline-rules`), not a workaround. A single top-level `.clinerules` *file* is only the alternative, simpler form Cline also supports.
- **Chosen design decision (mechanical fix, no ADR needed):** keep `.clinerules` as a directory (already forced by `TOOL_SKILLS_DIR=".clinerules/skills"`, and it is Cline's own supported multi-file rules format) and move the boot content to a file *inside* that directory instead of colliding with it. Set `TOOL_BOOT_FILE=".clinerules/00-planifest-boot.md"` in both `cline.sh` and `cline.ps1` (numeric prefix follows Cline's own documented convention for ordering rule files, and keeps `skills/` and the boot file as sibling entries under the same directory). No other script (`setup.sh`/`setup.ps1`/`write_boot_file`) needs structural changes — `write_boot_file()`'s existing `mkdir -p "$(dirname "$path")"` already creates `.clinerules/` correctly for a nested path, and `append_override_instructions()` operates on `TOOL_BOOT_FILE` generically, so it continues to work unchanged against the new path.

## Functional Requirements
- `planifest-framework/setup/cline.sh` sets `TOOL_BOOT_FILE=".clinerules/00-planifest-boot.md"` (no longer the bare `.clinerules` path that collides with `TOOL_SKILLS_DIR`'s parent directory).
- `planifest-framework/setup/cline.ps1` sets the equivalent `BootFile = '.clinerules\00-planifest-boot.md'`, keeping parity with `cline.sh`.
- No change to `TOOL_SKILLS_DIR` (`.clinerules/skills`) in either file — the collision is resolved by relocating the boot file, not the skills directory, per the chosen design decision above.
- `setup.sh cline` and `setup.sh all` complete without the "Is a directory" failure on a fresh workspace; the boot content is written to `.clinerules/00-planifest-boot.md` and is readable as a normal file.
- `append_override_instructions()` (which appends `planifest-overrides/instructions/*.md` content between sentinel markers into `TOOL_BOOT_FILE`) continues to work unmodified against the new nested path — verified by the regression test, not assumed.

## Acceptance Criteria
- [ ] `setup.sh cline` exits 0 on a fresh, disposable workspace (mirroring the `make_workspace()` pattern in `test-0000023-req-003-copilot-setup-self-copy.sh`).
- [ ] `setup.sh all` exits 0 on a fresh, disposable workspace — including the cline step, and without the "identical (not copied)"-style or "Is a directory" errors previously masked/unmasked per that same test's part (e) note.
- [ ] After `setup.sh cline`, `.clinerules/00-planifest-boot.md` exists as a regular file with the expected boot content, and `.clinerules/skills/` exists as a directory containing the copied skills — both coexist under `.clinerules/` with no collision.
- [ ] A new regression test `planifest-framework/tests/test-0000027-req-002-cline-path-collision.sh` (following the naming and structure convention of `test-0000023-req-003-copilot-setup-self-copy.sh` and `test-0000026-telemetry-failure-hook.sh`) proves: (a) `setup.sh cline` exits 0 on a fresh workspace, (b) `.clinerules/00-planifest-boot.md` exists and `.clinerules/skills/` exists as a directory, (c) `setup.sh all` exits 0 on a fresh workspace, (d) `cline.ps1` statically declares the equivalent `BootFile` value (parity check, no live PowerShell run required in this environment).
- [ ] `test-0000023-req-003-copilot-setup-self-copy.sh` part (e)'s existing assertion (`assert_exit_zero "$ALL_EXIT" ...`), previously expected to fail because of this exact cline.sh bug, now passes — confirming this fix removes the blocker that test's own comment names, without needing to edit that test's assertions.

## Dependencies
- None (independent of the other 7 items in this batch).

## Input Validation

Not applicable — this requirement changes a hardcoded setup-script path constant only; it does not introduce a new path that reads untrusted external content into displayed or injected output.
