---
title: "Backlog Entry: 0000043 - phase_start/phase_end hooks not wired in setup"
summary: "telemetry-standards.md describes phase_start/phase_end as hook-driven natively for tools with hook support, but this repo's own .claude/settings.json only has the context-pressure hook registered — no emit-phase-start.mjs/emit-phase-end.mjs entries exist, so those two event types have never been sent by the hook path, ever, under the current setup."
status: "open"
---
# Backlog Entry: 0000043 - phase_start/phase_end hooks not wired in setup

**Source feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source phase:** P2

**Date filed:** 2026-08-03

---

## Problem

`planifest-framework/standards/telemetry-standards.md` ("phase_start and phase_end Ownership") states: "Hooks emit `phase_start`/`phase_end` natively; the snippets below are the backup path for tools without hook support." Inspecting this repo's own `.claude/settings.json`, only one telemetry hook is actually registered — `PostToolUse` → `context-pressure.mjs`. There is no `emit-phase-start.mjs` or `emit-phase-end.mjs` entry anywhere in the hooks configuration, despite both scripts existing at `planifest-framework/hooks/telemetry/emit-phase-start.mjs` and `emit-phase-end.mjs` (confirmed present in the repo). This means `phase_start`/`phase_end` events have never been emitted via the hook path in this project, for any feature, under the current `.claude/settings.json` — a silent, total gap in two of the framework's 14 documented event types, with no failure marker either (a hook that's never invoked can't fail and can't write a marker — so this gap is invisible to the existing failure-detection mechanism entirely).

Discovered while investigating an unrelated `context-pressure` fetch-failure marker during feature 0000025's P2 — the fact that no equivalent markers existed for phase_start/phase_end turned out to mean "never wired," not "never failed."

## Suggested Action

Audit `setup-hook-integration`'s `setup.sh`/`setup.ps1` (and the Claude Code hook-config writer specifically) for why `--structured-telemetry-mcp` wires `context-pressure.mjs` but not `emit-phase-start.mjs`/`emit-phase-end.mjs`. Fix the setup script to wire all three telemetry hooks together (they're supposed to be gated by the same single flag per `0000018-ADR-001`'s "Unified Telemetry Signal" — this looks like a partial-wiring regression or an incomplete original implementation, not an intentional split). Also consider: since a never-invoked hook produces no failure marker, add a positive-presence check (e.g. at P0 discovery or in a setup-verification script) that confirms all three hooks are actually registered in the tool's hook config, not just that the unified signal flag was passed at install time.

## Why Deferred

Out of scope for 0000025 (that feature's stories are `planifest-framework` skill/process fixes; this is a `setup-hook-integration` component bug in the hook-wiring mechanism itself). Discovered mid-run, non-blocking for 0000025's own work, but a real and previously-invisible gap the human wants picked up next.
