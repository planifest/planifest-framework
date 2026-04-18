---
title: "Requirement: REQ-001 - Phase start fires deterministically"
summary: "phase_start telemetry event is emitted by a hook script, not by LLM instruction compliance."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-001 - Phase start fires deterministically

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-1; DD-001
**Priority:** must-have

---

## Functional Requirements

- A `PreToolUse` hook command is registered on each of the 7 phase skills (spec, adr, codegen, validate, security, docs, ship).
- The hook command invokes `emit-phase-start.mjs <phase>` via Node.js.
- `emit-phase-start.mjs` reads `PLANIFEST_SESSION_ID` and `PLANIFEST_TELEMETRY_URL` from the environment.
- The script POSTs a `phase_start` event to `${PLANIFEST_TELEMETRY_URL}/emit` with the standard telemetry envelope.
- The script completes silently (no stdout/stderr) when telemetry is unavailable or the sentinel is absent.
- The script aborts the HTTP request after 3 seconds and exits 0.

## Acceptance Criteria

- [ ] A `phase_start` event appears in telemetry for each of the 7 phases without any agent instruction compliance.
- [ ] The event is emitted before the first tool use within the phase.
- [ ] When `PLANIFEST_TELEMETRY_URL` is unset, the script exits 0 with no output.
- [ ] When the sentinel file is absent, the script exits 0 with no output.
- [ ] Hook command exits within 3 seconds under all conditions.

## Dependencies

- `PLANIFEST_TELEMETRY_URL` environment variable set in project environment.
- `structured-telemetry-mcp` server running and accepting POST to `/emit`.
- REQ-003 (flag-file guard) must be implemented alongside to prevent duplicate emissions.
