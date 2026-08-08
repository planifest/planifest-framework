---
title: "Backlog Entry: 0000068 - Extend the shared readStdin to the adapter and context-mode hooks"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000068 - Extend the shared readStdin to the adapter and context-mode hooks

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`0000028-req-002` collapsed 13 copies of `readStdin()` into `planifest-framework/hooks/enforcement/read-stdin.mjs`, and in doing so fixed a latent NFR-001 violation: 10 of those copies had no `stdin.on("error")` handler and would hang on a stdin stream error instead of exiting 0.

8 pre-extraction copies remain outside the two hook trees that req-002 scoped:

- `planifest-framework/hooks/adapters/`: `cline.mjs`, `codex.mjs`, `copilot.mjs`, `cursor.mjs`, `windsurf.mjs`
- `planifest-framework/hooks/context-mode/`: `block-bash.mjs`, `block-grep.mjs`, `block-webfetch.mjs`

The NFR-001 fix does not reach any of them. They retain the shape that hangs.

## Suggested Action

Trace the adapter and context-mode install paths through `setup.sh` and `setup.ps1` the way `0000028-ADR-002` traced the enforcement and telemetry paths, and decide which tree is the superset under those install conditions. The adapters install to a different destination (`{tool}/hooks/adapters/`, with the adapter deriving `HOOKS_DIR` from its own `dirname`), and `hooks/context-mode/` installs only under `--context-mode-mcp`, so neither placement follows from the existing analysis. Then rewire one caller at a time under `0000028-ADR-004`'s sequencing.

## Why Deferred

See `0000028`'s `tech-debt.md` TD-002: `req-002` and `ADR-002` scope the extraction to `hooks/enforcement/` and `hooks/telemetry/` and reason about placement purely in terms of those two trees' install conditions. Folding in a third and fourth tree without its own placement analysis is the exact failure ADR-002 exists to prevent, since an import that resolves the wrong way fails at ESM module-load time, before the hook's own try/catch, and so breaks the exit-zero invariant outright.
