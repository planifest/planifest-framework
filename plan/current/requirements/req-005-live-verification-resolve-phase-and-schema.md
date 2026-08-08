---
title: "Requirement: req-005 - live verification of resolve-phase and telemetry schema"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-005 - live verification of resolve-phase and telemetry schema

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source:** US-005
**Priority:** should-have

## User Story

As a framework maintainer, I want `resolve-phase.mjs` verified against a live hook firing rather than direct invocation, and the telemetry schema's loop and reversal fields confirmed or the gap recorded, so that both assumptions are proven rather than assumed.

## Functional Requirements

- Verify by execution, not by reading test output. `planifest-verify-by-execution` governs this requirement (loaded by the P4 validate-agent).
- Covers backlog 0000058 and 0000053.
- Precondition: depends on req-004 (install refresh and phase hook registration) completing first. Nothing here can fire until the phase hooks are actually registered against real hook events.

### 0000058 - resolve-phase.mjs live firing

`planifest-framework/hooks/telemetry/resolve-phase.mjs` has two assumptions never checked by a real hook firing, only by direct script invocation during 0000027's P3/P4:

1. **Matcher assumption:** the resolver is wired as a `PreToolUse` hook matched on the literal string `"Skill"` (see the file's own header comment, lines 24 and 154: `if (input?.tool_name !== "Skill") process.exit(0);`). This assumes Claude Code's `PreToolUse` event fires for Skill tool invocations and that `tool_name` is literally `"Skill"` on that event's JSON payload. Never observed live.
2. **Field assumption:** `extractSkillName()` (lines 119-122) reads `tool_input.skill`, falling back to `tool_input.name`, to identify which phase-agent skill was invoked. This assumes the Skill tool's `PreToolUse` payload carries the invoked skill's name under one of those two keys. Never observed live.

If either assumption is wrong, `phase_start` silently fails to fire for that transition. This fails open by design (ADR-005, no session-blocking risk), so the defect is a quiet telemetry gap, not a crash. That is exactly the gap this requirement exists to close by observation.

- Run a live orchestrator session through at least one full phase transition (P0 coaching into P1 spec-agent, which this run itself constitutes) and confirm `resolve-phase.mjs` fires: check for the phase marker at `.claude/.planifest-active-phase`, and for a delivered or durably-marked `phase_start` event corresponding to the correct phase argument.
- If the live `PreToolUse` payload's `tool_name` or `tool_input` shape differs from the assumption, correct the matcher or `extractSkillName()` field access in `resolve-phase.mjs` to match the observed shape, and record the correction.
- If the live shape matches the assumption exactly, record that both assumptions are confirmed, citing the observed payload.

### 0000053 - telemetry schema loop and reversal fields

`planifest-framework/standards/telemetry-standards.md` (`## Loop and Reversal Events`, feature 0000016) documents `loop_iteration`, `phase_reversal_petitioned`, `phase_reversal_granted`, and `phase_reversal_denied` as event types the schema must accept. Root Cause B of the 0000017 RCA (missing `loop_iteration`/`phase_reversal_*` schema entries in `structured-telemetry-mcp`'s deployed schema) was never checked, because no loop or reversal event has fired in any prior feature run (0000024's Deferred Items row, backlog 0000053).

- Confirm whether `structured-telemetry-mcp`'s deployed schema accepts an envelope carrying `event: "loop_iteration"` and each of the three `phase_reversal_*` event names, with their documented `data` payload shapes.
- Verification requires an actual loop or reversal event to fire against the live backend. This run's own `planifest-scope-lock-agent` dispatch at P0 or any loop entered under `planifest-loop-runner` during this feature's build is a candidate trigger.
- If no loop or reversal event fires during this run's execution, the acceptance is that this gap is explicitly recorded as still-open in this requirement's completion note, not silently passed as verified. A fresh backlog entry is filed against `structured-telemetry-mcp` only if a fired event is observed to be rejected or malformed, per backlog 0000053's own suggested action (do not reopen 0000053 speculatively).

## Acceptance Criteria

- [ ] req-004 confirmed complete before this requirement's verification steps begin.
- [ ] `resolve-phase.mjs` observed firing from a real `PreToolUse` hook event during a live phase transition in this repo, not from a direct script invocation.
- [ ] The observed `tool_name` and `tool_input` shape for that event is stated explicitly (matched assumption, or corrected code plus the observed shape).
- [ ] If the matcher or field assumption was wrong, `resolve-phase.mjs` is corrected and the fix is itself verified live (a second observed firing after the correction).
- [ ] The telemetry schema's acceptance of `loop_iteration` and `phase_reversal_*` fields is either confirmed against a fired event, or the gap is explicitly recorded as unverified this run with the reason (no loop/reversal event fired).
- [ ] Findings for both 0000058 and 0000053 are recorded in `plan/current/build-log.md` at the phase this requirement executes in.

## Dependencies

- req-004 (install refresh and phase hook registration): hard precondition, nothing here is observable until the phase hooks are registered.
- `planifest-verify-by-execution` skill, loaded by the P4 validate-agent.
- `planifest-loop-runner`, for the loop/reversal event trigger candidate under 0000053.
- Live telemetry backend on `PLANIFEST_TELEMETRY_URL`, confirmed healthy at P0.
