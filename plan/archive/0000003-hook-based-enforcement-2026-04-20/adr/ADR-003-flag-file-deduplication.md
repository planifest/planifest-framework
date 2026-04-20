---
title: "ADR-003: Temp filesystem flag file for phase_start deduplication"
summary: "A per-session-per-phase flag file in the OS temp directory prevents duplicate phase_start emissions. The flag file doubles as a start-timestamp store for duration_ms calculation."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Temp filesystem flag file for phase_start deduplication

**Skill:** [adr-agent](../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** claude-code
**Model:** claude-sonnet-4-5
**Feature:** 0000003-hook-based-enforcement
**Component:** planifest-framework/hooks/telemetry/
**Status:** accepted
**Date:** 2026-04-18

---

## Context

`PreToolUse` fires on every tool call within a phase. Without a guard, `emit-phase-start.mjs` would emit a `phase_start` event for every tool use — potentially dozens per phase. The telemetry backend receives duplicate events and the data is unusable. The hook script must deduplicate emissions to exactly once per session per phase.

The deduplication state must be:
- Persistent across multiple invocations within the same OS process context (the hook fires in a new child process each time)
- Not require any external service (the hook has no npm dependencies)
- Not leave permanent state after the session ends
- Readable by `emit-phase-end.mjs` to compute `duration_ms`

---

## Decision

Use a flag file at `{os.tmpdir()}/planifest-telemetry/phase-start-{session_id}-{phase}`.

On first invocation: check for flag file absence → emit `phase_start` → write flag file with ISO 8601 start timestamp as content.

On subsequent invocations: detect flag file exists → exit 0 silently (no emission).

`emit-phase-end.mjs` reads the flag file to retrieve the start timestamp and computes `duration_ms = Date.now() - startTimestamp`.

**Session ID fallback:** When `PLANIFEST_SESSION_ID` is absent, `emit-phase-start.mjs` reads/creates `{cwd}/.claude/.planifest-session` containing a generated UUID. This provides a stable session ID across process restarts within the same project (DD-001, R-005 mitigation).

Flag files are OS-temp-managed (cleaned on reboot) and deleted by the ship-agent at Phase 7 alongside `.skips` and `.planifest-session`.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| In-memory deduplication (module-level variable) | Zero filesystem I/O | Hook scripts run as separate child processes each invocation; in-memory state does not persist between calls | Functionally broken — each invocation is a fresh process |
| MCP server as state store (call `store_state` before emitting) | No filesystem dependency | Requires MCP to be active; adds network round-trip; hook scripts must have zero external dependencies | Violates the no-external-dependencies NFR; MCP optional |
| SQLite file in project root | Durable, queryable | overkill; requires sqlite3 npm dep; contention risk | Violates Node.js built-ins only constraint |
| Git-tracked state file in `plan/current/` | Visible, auditable | Would appear as dirty working tree after every hook fire; causes noise in git status | Unacceptable UX regression |
| Environment variable (set in parent process) | Zero I/O | Hook child processes do not inherit env vars set by siblings; not controllable from hook script itself | Technically infeasible in hook execution model |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `planifest-framework/hooks/telemetry/emit-phase-start.mjs` | Writes flag file; reads `.planifest-session` for session ID |
| `planifest-framework/hooks/telemetry/emit-phase-end.mjs` | Reads flag file for start timestamp |
| `planifest-framework/skills/planifest-ship-agent/SKILL.md` | Must delete flag files and `.planifest-session` at Phase 7 |
| `.claude/.planifest-session` | Created by hook on first invocation when session ID absent |

---

## Consequences

**Positive:**
- Zero external dependencies — pure filesystem, Node.js built-ins only
- Deduplication is correct across process restarts within a session
- Start timestamp stored in flag file gives accurate `duration_ms` without any additional IPC
- OS temp cleanup handles stale files without any active cleanup code

**Negative:**
- Flag files accumulate in `{tmpdir}` until OS cleanup or ship-agent deletion; on long-running systems without reboots, old files may linger
- A crash mid-write (between emit and file creation) leaves the event emitted but the flag absent — the next tool use re-emits `phase_start`. This is a known edge case; impact is a single duplicate event in pathological conditions.

**Risks:**
- If `os.tmpdir()` points to a read-only filesystem (e.g. certain containerised environments), the flag file cannot be written. The script must handle this gracefully: catch the write error, proceed with emission (no deduplication), exit 0.

---

## Related ADRs

- ADR-001 - related-to (flag file mechanism applies to all tiers that use emit-phase-start.mjs)
- ADR-002 - depends-on (session_id is read from common envelope or .planifest-session fallback)
- ADR-005 - related-to (exit-0 failure mode governs write-error handling)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent. Path: `plan/current/adr/ADR-003-flag-file-deduplication.md`*
