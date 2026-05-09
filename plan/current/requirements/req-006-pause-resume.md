---
title: "Requirement: REQ-006 - pause-resume"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-006 - pause-resume

**Feature:** 0000009-framework-rail-tightening
**Source:** Feature brief AC — pause.md written on command; resume detection restores from exact pause point
**Priority:** must-have

---

## Functional Requirements

- On explicit human command (e.g. "pause", "save state", "write pause file"), the orchestrator writes `plan/current/pause.md` capturing:
  - Current phase (e.g. `P3`)
  - Active task or step within the phase (e.g. "writing req-003")
  - Last completed artefact (path)
  - In-progress state (what was being done when paused, enough to resume without re-asking the human)
  - Timestamp (ISO 8601)
- On session start, resume detection (already present in orchestrator SKILL.md) is extended to also read `plan/current/pause.md` if it exists
- When `pause.md` is present, the orchestrator opens with `Px: Resuming from pause — {summary of pause state}` and continues from the exact point captured, without re-coaching or re-asking questions already answered
- After successfully resuming and the human confirms continuation, `pause.md` is deleted (consumed)
- `pause.md` format:

  ```markdown
  ---
  date: {YYYY-MM-DD}
  phase: {Px — Phase Name}
  status: paused by human
  ---

  # Session Pause

  ## Current Phase
  {phase name and number}

  ## Active Task
  {what was being done}

  ## Last Completed Artefact
  {path}

  ## In-Progress State
  {enough detail to resume without re-asking}
  ```

## Acceptance Criteria

- [ ] On command, orchestrator writes `plan/current/pause.md` with all required fields
- [ ] Orchestrator SKILL.md resume detection section reads `pause.md` if present
- [ ] On resume with `pause.md` present, orchestrator opens with `Px: Resuming from pause` and the summary
- [ ] `pause.md` is deleted after successful resume confirmation
- [ ] `pause.md` base filename is added to `ALWAYS_PERMITTED_FILES` in gate-write.mjs so it is writable without design.md

## Dependencies

- REQ-007 (gate-write fix ensures pause.md writes to plan/current/ are not blocked by missing design.md when plan/current/ is in always-permitted state — however pause.md should also be added to ALWAYS_PERMITTED_FILES for belt-and-suspenders)
