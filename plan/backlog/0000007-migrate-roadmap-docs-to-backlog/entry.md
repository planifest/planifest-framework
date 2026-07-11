---
title: "Backlog Entry: 0000007 - Migrate or close orphaned roadmap docs 0008b/0008c"
summary: "docs/0008b and docs/0008c are pre-backlog-mechanism roadmap items sitting unactioned in docs/ since April 2026 — fold into plan/backlog/ or close."
status: "open"
---
# Backlog Entry: 0000007 - Migrate or close orphaned roadmap docs 0008b/0008c

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** post-ship assessment
**Date filed:** 2026-07-11

---

## Problem

`docs/0008b--feature--structured-telemetry-framework-integration.md` and `docs/0008c--feature--structured-telemetry-mcp-changes.md` are "Roadmap Item" documents dated April 2026, predating the `plan/backlog/` mechanism this feature (0000016) introduced. They sit in `docs/` — the living-state layer — rather than as change artifacts, and neither has been actioned in ~3 months. `0008b` (wire the framework to telemetry) is now partially superseded: 0000016 added telemetry envelope docs, loop event types, and emission-gate conventions independently of this roadmap item. `0008c` (schema gaps in the deployed MCP server) is still fully open and is the direct source for backlog `0000005`.

## Suggested Action

For `0008c`: no action needed beyond what `0000005` already covers — leave it in place as the technical reference `0000005` points to, but mark it superseded-by-backlog-entry once `0000005` is picked up. For `0008b`: assess what remains undone versus what 0000016 already delivered piecemeal (emission gate, event envelope, loop event types); either close it with a note on what shipped, or convert the remainder into a proper backlog entry. General principle going forward: new roadmap-style observations should go straight to `plan/backlog/`, not `docs/`, now that the mechanism exists.

## Why Deferred

Judgment call on what's superseded vs. still-needed requires reading `0008b` in full against the current state of the framework's telemetry integration — a small triage task, not a mechanical fix.
