---
title: "Requirement: REQ-003 - Flag-file guard prevents duplicate phase_start"
summary: "A temp-file sentinel ensures phase_start is emitted at most once per session per phase."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-003 - Flag-file guard prevents duplicate phase_start

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-3; DD-001
**Priority:** must-have

---

## Functional Requirements

- `emit-phase-start.mjs` writes a flag file at `{os.tmpdir()}/planifest-telemetry/phase-start-{session_id}-{phase}` on first emission.
- The flag file content is the emission timestamp in ISO 8601 UTC format (used by REQ-002 for `duration_ms`).
- On subsequent calls within the same session, the script detects the flag file and exits 0 without emitting.
- Flag files are written atomically (write to a temp path, then rename) to prevent race conditions.
- The `planifest-telemetry/` directory is created if it does not exist.
- **Session ID fallback:** If `PLANIFEST_SESSION_ID` is not set, `emit-phase-start.mjs` reads `{cwd}/.claude/.planifest-session`. If that file does not exist, it creates it with a generated UUID. This value is used as the session ID for the flag file key, ensuring the guard is consistent across process restarts within the same project.
- The `.planifest-session` file is deleted by the ship-agent at Phase 7 alongside `.skips`.

## Acceptance Criteria

- [ ] Zero duplicate `phase_start` events per session per phase in telemetry data.
- [ ] Flag file is present at expected path after first emission.
- [ ] Second invocation of emit-phase-start.mjs with same session_id + phase exits 0 without emitting.
- [ ] Flag file directory is created automatically if missing.

## Dependencies

- REQ-001 (phase_start hook must invoke emit-phase-start.mjs).
- `PLANIFEST_SESSION_ID` environment variable available at hook execution time (optional — fallback uses `.planifest-session` file).
