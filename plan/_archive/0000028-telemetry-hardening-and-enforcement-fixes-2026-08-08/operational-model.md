---
title: "Operational Model - telemetry-hardening-and-enforcement-fixes"
summary: "Runbook triggers, on-call expectations, and alerting thresholds for this feature."
status: "draft"
version: "0.1.0"
---
# Operational Model - telemetry-hardening-and-enforcement-fixes

**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes

## Scope of this document

This is a local developer-tooling framework. There is no production deployment, no service to page,
and no on-call rota. Hooks run as short-lived subprocesses of the host tool (Claude Code, Cursor,
Cline, etc.) on the human on the loop's own machine. "Operations" here means: what the human on the
loop does when something this feature produces needs a human decision, and how to recover local
install state that this feature does not track in git. Nothing below should be read as implying a
paging or SRE apparatus that does not exist.

## Runbook triggers

### 1. A durable failure marker appears under `plan/.telemetry-failures/`

**Trigger:** `check-telemetry-failures.mjs` (a `UserPromptSubmit` hook) injects a reminder into
context at the start of a turn when one or more `*.json` marker files exist in that directory. A
marker file existing on disk IS the "unacknowledged" signal; there is no separate flag.

**What the human on the loop does**, per `telemetry-standards.md`'s Failure Detection and Interactive
Recovery protocol:

1. Read the marker's `hook`, `error_type`, `error_message`, and `occurrences` fields (surfaced in the
   injected context).
2. Answer the block-or-proceed question the orchestrator raises for that `root_cause_key`.
3. Record the answer in `plan/current/build-log.md`.
4. Delete the marker file. Deletion is what marks the root cause "already asked about" - the
   `check-telemetry-failures.mjs` hook is read-only and never deletes markers itself.

This is unchanged by this feature. What changes is what reaches this step at all: after req-001,
a backend caught in a brief restart window no longer produces a marker, because the retry absorbs it.
Only a network-level failure that survives 2 attempts within the 300ms retry budget, or an HTTP 4xx/5xx
response, reaches this runbook.

### 2. Telling a real backend outage from a listener gap, now that retry absorbs the listener-gap case

Before this feature, any network-level failure produced a marker, so the human on the loop could not
tell a one-off restart from a sustained outage without checking the backend directly. After this
feature:

- **Retried and invisible:** a listener that appears within the retry window (2 attempts, 300ms
  budget) delivers the event and writes no marker. This case now requires no human attention at all.
- **Marker still written:** retry exhaustion (no listener across both attempts) or an HTTP error status
  (a listener answered and rejected the event). Both are recorded exactly once via the durable marker
  mechanism above.

Because retry narrows the false-positive class rather than widening it, a marker appearing after this
feature ships is closer to a genuine signal than before. If markers recur repeatedly for the same
`root_cause_key`, that is now a stronger indicator of a sustained backend problem, not tooling noise -
check the backend at `PLANIFEST_TELEMETRY_URL` directly (e.g. is the process listening on
`127.0.0.1:3741`) rather than assuming it is another false positive.

### 3. Recovering a broken or stale hook install

**Trigger:** phase telemetry hooks (`emit-phase-start.mjs`, `emit-phase-end.mjs`) are not firing, or
hook wiring appears to have regressed after a framework update.

**Why `git checkout` does not help:** `.claude/` (or the equivalent tool directory) is gitignored
wholesale. It is local machine state, not repo state. `planifest-framework/hooks/` is the tracked
source of truth; the live install under `.claude/` is a derived artifact that can only be reconstructed
by re-running setup, never restored from git history.

**Recovery procedure:** invoke the `planifest-refresh-setup` skill for the affected tool. It:

1. Reads `{tool-dir}/.planifest-setup-flags` if present (high-confidence source for previously-used
   flags), or infers flags from installed hook wiring if the marker file is absent, incomplete, or for
   a different tool.
2. Reports the recovered flags and their confidence/source to the human on the loop for confirmation -
   always, with no bypass, even at full confidence.
3. Re-invokes `setup.sh`/`setup.ps1` with those flags, which rewrites the hook wiring including the
   phase telemetry hooks (`merge_telemetry_hook_settings()`).

This is the same procedure whether the install is merely stale (never had phase hooks registered) or
actively broken (a bad edit left a hook referencing a module that no longer exists per R-001 in
`risk-register.md`).

### 4. Clearing an acknowledged marker

Covered by runbook trigger 1, step 4 above: delete the marker file under `plan/.telemetry-failures/`
once the block-or-proceed answer is recorded in `build-log.md`. "Clearing a marker means acknowledged,
not resolved" - deletion is a record-keeping action, not a claim that the underlying cause was fixed.
There is no separate clear/dismiss command; the marker is a plain JSON file and deletion is a plain
file delete.

## What this document deliberately does not contain

- **Alerting thresholds in the monitoring sense.** There is no metrics pipeline, no dashboard, and no
  paging integration. The only "alert" is the `UserPromptSubmit` context injection described above,
  which fires on the human on the loop's next turn, not in real time.
- **On-call rotation or escalation chain.** Not applicable. One human on the loop per session; the
  runbook above is addressed to them directly.
- **Rollback procedure for the telemetry backend itself.** The backend is external to this repo and
  cannot be modified here (see `design.md` constraints); this feature has no operational lever over it
  beyond the retry/marker behaviour described above.
