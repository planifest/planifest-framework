---
title: "Backlog Entry: 0000055 - telemetry hook backend_url shell interpolation"
summary: "merge_telemetry_hook_settings() in setup.sh/setup.ps1 interpolates a CLI-supplied backend_url directly into a shell command string written into the target's hook config, a pre-existing pattern now propagated to 2 more call sites by feature 0000027."
status: "open"
---
# Backlog Entry: 0000055 - telemetry hook backend_url shell interpolation

**Source feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source phase:** P5
**Deferral source:** discovered mid-flight
**Date filed:** 2026-08-08

---

## Problem

`merge_telemetry_hook_settings()` in `planifest-framework/setup.sh` (and the equivalent in `setup.ps1`) builds each telemetry hook's `command` string by interpolating `backend_url` (a CLI-supplied value, e.g. from `--structured-telemetry-mcp-url=...`) directly into a shell command: `PLANIFEST_TELEMETRY_URL=$backend_url node $hooks_dir/{script}.mjs`. That string is written into `.claude/settings.json` (or the target tool's equivalent) as a hook `command`, which the shell executes verbatim every time the hook fires. A `backend_url` containing shell metacharacters (backticks, `;`, `$(...)`, etc.) could result in command injection at hook-fire time.

This pattern already existed for `context-pressure.mjs`'s registration before feature `0000027`. That feature's req-001 (wiring `emit-phase-start.mjs`/`emit-phase-end.mjs` via a new `resolve-phase.mjs` interposer) replicated the exact same interpolation for 2 more command strings (`start_cmd`, `end_cmd`), propagating the existing risk to more call sites rather than introducing a new one. Found during `0000027`'s own P5 security review; fixing the pre-existing pattern across all telemetry hook registrations (not just the 2 new ones) was judged out of scope for that feature.

## Suggested Action

Validate or reject `backend_url` values containing shell metacharacters before interpolation, across all telemetry hook command strings in `setup.sh`/`setup.ps1` (`context-pressure.mjs`, `resolve-phase.mjs`-wrapped `emit-phase-start.mjs`/`emit-phase-end.mjs`). Alternatively, move the URL out of the inline command string entirely — e.g. write it to a small env-file the hook script reads at runtime, rather than embedding it in the `command` value written to the settings file.

## Why Deferred

Fixing the pre-existing pattern across all telemetry hook registrations (not just the 2 new call sites `0000027` touched) is separate, unscoped work — `0000027`'s own 8 items did not include "harden telemetry hook command construction" as a requirement. Non-blocking: `backend_url` is operator-supplied at install time (not externally/remotely controlled), so exploitability requires the installing operator to pass a malicious value to their own setup command.
