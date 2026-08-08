---
title: "Backlog Entry: 0000058 - verify resolve-phase.mjs against a live hook firing"
summary: "resolve-phase.mjs's PreToolUse(Skill) matcher and tool_input.skill field assumption were only verified by direct script invocation during P3/P4 codegen, never by an actual live Claude Code hook firing, since no live orchestrator session was available in that environment."
status: "open"
---
# Backlog Entry: 0000058 - verify resolve-phase.mjs against a live hook firing

**Source feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`planifest-framework/hooks/telemetry/resolve-phase.mjs` (req-001/req-004) infers the active pipeline phase from a `PreToolUse` hook matched on `"Skill"`, reading `tool_input.skill` (falling back to `tool_input.name`) to identify which phase-agent skill was invoked. This was modeled on this repo's existing hook precedent (matcher on a literal tool name, e.g. `"Bash"`/`"Grep"`/`"Write"`) and verified by directly piping crafted JSON into the script during P3/P4 — but never by an actual live Claude Code session invoking a real phase-agent Skill and observing the hook fire correctly end-to-end. See TD-002 in `plan/current/recommendations.md` (feature 0000027) and REC-002 there.

If the Skill tool's actual `tool_input` shape differs from what this hook assumes, `phase_start` would silently fail to fire (fail-open by design, per ADR-005) — not a crash, but a quiet telemetry gap of exactly the kind this feature exists to close.

## Suggested Action

Run a live orchestrator session through at least one full phase transition (e.g. P0 coaching into P1 spec-agent) and confirm a `plan/.telemetry-receipts/`-adjacent signal (or a manually-added debug log) shows `resolve-phase.mjs` correctly firing `emit-phase-start.mjs` with the right phase argument. Adjust the matcher/field-name assumption if the live shape differs.

## Why Deferred

No live orchestrator session with a real Skill-tool invocation was available in the environment where `0000027`'s P3/P4 ran. Non-blocking: the mechanism fails open (no session-blocking risk), so this is a correctness/completeness follow-up, not a stability risk.
