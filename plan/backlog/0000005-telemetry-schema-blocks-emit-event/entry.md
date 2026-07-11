---
title: "Backlog Entry: 0000005 - Telemetry MCP schema gap blocks emit_event"
summary: "emit_event rejects every call with \"(root): must be object\" (R-009); the fix is already spec'd in docs/0008c but unactioned since April 2026."
status: "open"
---
# Backlog Entry: 0000005 - Telemetry MCP schema gap blocks emit_event

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** post-ship assessment
**Date filed:** 2026-07-11

---

## Problem

`emit_event` rejected every call made during the 0000016 pipeline run with `"(root): must be object"` (recorded as risk R-009, execution-plan Q, and REC-001). No `phase_start`/`phase_end`/`adr_decision`/`loop_iteration`/`phase_reversal_*` events landed for the entire run — telemetry was fully inert, compensated only by manual build-log notes. This is not a new discovery: `docs/0008c--feature--structured-telemetry-mcp-changes.md` (dated April 2026, live exploration of the deployed `structured-telemetry-mcp` server at `C:/d/planifest/structured-telemetry-mcp/`) already documents multiple schema gaps in `schemas/telemetry-event.schema.json` — missing event types, missing `$defs`, missing `data.oneOf` entries — and has sat unactioned for roughly three months. NFR-004 (cost visibility — every loop iteration/reversal attributable in telemetry) and the entire Wave 1 promotion decision for 0000016's new loops depend on this working.

## Suggested Action

Cross-repo fix: implement the schema additions specified in `docs/0008c` against `structured-telemetry-mcp` (separate repo, not this one). Before implementing, reproduce the exact `emit_event` call that failed during 0000016 (envelope + `loop_iteration`/`phase_reversal_petitioned` data shapes) against the current live schema to confirm whether the `"(root): must be object"` error is the same root cause 0008c already describes, or a newer regression on top of it.

## Why Deferred

Cross-repo — cannot be fixed from `planifest-framework` alone; needs its own pipeline run against `structured-telemetry-mcp`.
