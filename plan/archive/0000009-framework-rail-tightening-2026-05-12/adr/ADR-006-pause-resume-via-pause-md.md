---
title: "ADR-006: Pause and resume via plan/current/pause.md file"
summary: "The orchestrator's pause/resume mechanism uses a single file at plan/current/pause.md containing phase, active task, last artifact, and in-progress state. Presence of the file signals a paused session; its content is the resume instruction."
status: "accepted"
version: "0.1.0"
---
# ADR-006 - Pause and resume via plan/current/pause.md file

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000009-framework-rail-tightening
**Component:** planifest-framework
**Status:** accepted
**Date:** 09 May 2026

---

## Context

REQ-006 requires the orchestrator to support a pause/resume command. When the human issues a pause command, the orchestrator must snapshot the current pipeline state so that a future session can resume from exactly the same point without re-coaching or re-running completed phases.

Several questions needed answering:
- What state must be captured to enable exact-point resume?
- Where does that state live (in-memory only, a new file, appended to an existing file)?
- How does the resume detection logic discover and consume it?
- What happens to the pause record after the session resumes?

The existing resume detection in the orchestrator checks `plan/current/` for artifact presence. Any resume mechanism must integrate with this existing logic without requiring a separate detection pass.

---

## Decision

A file `plan/current/pause.md` is written when the human issues a pause command. The file contains:

- **phase** — the current phase identifier (e.g. `P3`)
- **active_task** — the task in progress at pause time (e.g. "implementing REQ-003 subagent decomposition")
- **last_artifact** — the last file written or action completed before pause
- **in_progress_state** — a free-text description of what was partially completed and what remains, sufficient for the orchestrator to reconstruct the execution context

The file is YAML frontmatter plus a Markdown body. The frontmatter carries machine-readable fields (phase, active_task, last_artifact); the body carries the human-readable in-progress state narrative.

On resume, the orchestrator's existing `plan/current/` scan detects `pause.md`. If found, it opens with `Px: Resuming — {active_task}` and reads the in-progress state to restore context. After the session is fully resumed and the interrupted task is re-engaged, `pause.md` is deleted.

`pause.md` is added to `ALWAYS_PERMITTED_FILES` in `gate-write.mjs` so it can be written at any pipeline phase, including phases where `design.md` may not yet exist or has been cleared.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Append pause state to `build-log.md` | No new file; build log is already the pipeline record | Build log is append-only telemetry — not read by the orchestrator for control flow; pause state would not be discovered by resume detection | Wrong artifact type; not read at resume |
| In-memory only (no file) | No file writes | Lost on session end; resume impossible across session boundaries | Violates the persistence requirement in REQ-006 |
| Separate `plan/current/session-state.md` with full pipeline state | Comprehensive; enables rich resume | Over-engineered for the use case; the existing artifact scan already reconstructs most state; only the interrupted task context needs capturing | Complexity without benefit |
| Append to `.orchestrator-active` | Already a session sentinel | `.orchestrator-active` is a boolean sentinel (presence = active); adding structured state conflates the sentinel's purpose; existing consumers expect no content | Conflates two concerns |
| Use a `plan/pauses/` directory with timestamped files | Supports multiple pauses history | Resume logic must pick the latest; adds directory; history is already in build-log | Over-engineered; build log provides history |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | Orchestrator SKILL.md updated with pause command handler and resume detection for `pause.md`; `gate-write.mjs` updated to add `pause.md` to `ALWAYS_PERMITTED_FILES`; `pause.md` template added to `templates/` |

---

## Consequences

**Positive:**
- Pause state survives session boundaries — human can close the tool, reopen, and resume exactly
- Resume detection reuses the existing `plan/current/` scan — no new detection logic needed
- `pause.md` is self-documenting: the human can read it directly to understand where the session was paused
- Deleted on resume — no stale state accumulates

**Negative:**
- If the session ends ungracefully (crash, kill) without writing `pause.md`, resume falls back to the standard artifact-scan resume (phase re-detection from artifacts) — slightly less precise but still functional
- `pause.md` must be added to `ALWAYS_PERMITTED_FILES` in gate-write; this is a mechanical change but must not be forgotten

**Risks:**
- If `pause.md` is not deleted after resume and the pipeline completes, P7 will archive it alongside other `plan/current/` artifacts — harmless but slightly noisy; mitigated by explicit deletion in the resume handler

---

## Related ADRs

- ADR-005 — gate-write always-permitted list is the mechanism that allows `pause.md` to be written at any phase

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by planifest-adr-agent.*
