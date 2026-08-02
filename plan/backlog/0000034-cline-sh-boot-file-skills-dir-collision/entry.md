---
title: "Backlog Entry: 0000034 - cline.sh boot-file/skills-dir path collision"
summary: "setup/cline.sh sets TOOL_SKILLS_DIR=\".clinerules/skills\" and TOOL_BOOT_FILE=\".clinerules\" to colliding paths, so writing the boot file after the skills dir is mkdir -p'd fails with 'Is a directory', aborting setup.sh under set -euo pipefail. Previously masked by copilot's self-copy crash (req-003, 0000023) aborting 'setup.sh all' first; now unmasked."
status: "open"
---
# Backlog Entry: 0000034 - cline.sh boot-file/skills-dir path collision

**Source feature:** 0000023-framework-pipeline-fixes
**Source phase:** P3 (Codegen), discovered while implementing and verifying req-003 (copilot self-copy fix)
**Date filed:** 2026-08-02

---

## Problem

In `planifest-framework/setup/cline.sh`, `TOOL_SKILLS_DIR=".clinerules/skills"` and `TOOL_BOOT_FILE=".clinerules"` resolve to the same path once `setup.sh`'s `copy_skills()` does `mkdir -p "$target_dir"` for the skills dir (creating `.clinerules` as a directory) and `write_boot_file()` later does `echo "$content" > "$path"` for the boot file at that same `.clinerules` path. Since `.clinerules` is already a directory by that point, the `>` redirection fails with "Is a directory", and `setup.sh` runs under `set -euo pipefail`, so this aborts the entire run.

This was previously masked: `bash planifest-framework/setup.sh all` processes `copilot` before `cline` in its tool list, and copilot had its own self-copy crash (fixed under req-003, feature 0000023) that aborted `all` before it ever reached `cline`. Now that req-003's copilot fix has landed, `setup.sh all` gets further and hits this `cline.sh` bug instead — confirmed via a fresh disposable-workspace run: `planifest-framework/setup.sh: line 163: <tmp>/.clinerules: Is a directory`.

Check `planifest-framework/setup/cline.ps1` for the same issue on the PowerShell side (likely the equivalent `SkillsDir`/`BootFile` collision).

## Suggested Action

Change either `TOOL_SKILLS_DIR` or `TOOL_BOOT_FILE` in `cline.sh` (and the equivalent in `cline.ps1`) so they no longer collide — e.g. keep the boot file at `.clinerules` only if the skills dir moves elsewhere, or vice versa; check Cline's actual expected layout before choosing which one to relocate. Add a regression test asserting `setup.sh cline` and `setup.sh all` both exit 0 on a fresh workspace, following the same pattern used for the req-003 copilot regression test (`planifest-framework/tests/test-0000023-req-003-copilot-setup-self-copy.sh`).

## Why Deferred

Discovered as a side effect of fixing an unrelated bug (req-003, copilot's self-copy crash) in feature 0000023 — touching `cline.sh`/`cline.ps1` was explicitly out of scope for that requirement. Needs its own investigation into Cline's actual expected directory layout before a fix can be proposed with confidence.
