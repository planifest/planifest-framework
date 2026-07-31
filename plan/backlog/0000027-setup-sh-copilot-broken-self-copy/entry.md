---
title: "Backlog Entry: 0000027 - setup.sh/setup.ps1 copilot crashes on every run (self-copy bug)"
summary: "setup/copilot.sh sets TOOL_HOOK_ADAPTER_DEST to the exact same path as TOOL_HOOK_ADAPTER_SRC, so cp fails with 'identical, not copied' (exit 1) and set -euo pipefail aborts setup.sh entirely on every invocation of the copilot target."
status: "open"
---
# Backlog Entry: 0000027 - setup.sh/setup.ps1 copilot crashes on every run (self-copy bug)

**Source feature:** 0000020-setup-refresh-skill
**Source phase:** P5 (Security)
**Date filed:** 2026-08-01

---

## Problem

`planifest-framework/setup/copilot.sh` declares:

```
TOOL_HOOK_ADAPTER_SRC="hooks/adapters/copilot.mjs"
TOOL_HOOK_ADAPTER_DEST="planifest-framework/hooks/adapters/copilot.mjs"
```

Both resolve to the identical absolute path (`$SCRIPT_DIR/hooks/adapters/copilot.mjs` for the source, `$PROJECT_ROOT/planifest-framework/hooks/adapters/copilot.mjs` for the dest, which is the same file). `install_tier1_hooks` in `setup.sh` copies source to dest with `cp`. On a `cp` implementation where source and destination are the same file (confirmed on macOS/BSD `cp`), the command prints `cp: <path> and <path> are identical (not copied).` and exits 1. `setup.sh` runs under `set -euo pipefail`, so this exit code aborts the entire script immediately, every time `setup.sh copilot` (or `setup.sh all`, which includes copilot) is invoked, on any repo, not just this one.

Discovered while running `setup.sh copilot` in a disposable temp workspace during 0000020's P5 security review, to verify the new `.planifest-setup-flags` marker file's gitignore coverage across all tools. GNU `cp` (Linux) may behave differently (skip silently instead of erroring) — the severity on Linux/CI is unconfirmed and should be checked as part of the fix.

## Suggested Action

Set `TOOL_HOOK_ADAPTER_DEST` in `setup/copilot.ps1`/`setup/copilot.sh` to an actual project-local destination consistent with the other Tier 1 tools (e.g. a path under `.github/`), not a path back into `planifest-framework/` itself. Add a regression test asserting `setup.sh copilot` (and `setup.ps1 copilot`) exits 0 on a fresh workspace, since the existing test suite apparently did not catch this (no live-invocation test currently runs `setup.sh copilot` end to end).

## Why Deferred

Unrelated to 0000020's scope (flag reconstruction/persistence); this is a pre-existing defect in the copilot tool config, not something introduced by this feature. High severity (copilot setup is completely non-functional) but needs its own investigation into GNU vs BSD `cp` behaviour and the correct destination path before a fix can be proposed.
