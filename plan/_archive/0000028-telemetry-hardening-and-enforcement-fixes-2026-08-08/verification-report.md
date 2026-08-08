---
title: "Verification Report - 0000028-telemetry-hardening-and-enforcement-fixes"
summary: "Acceptance criteria verified by running the software, not by reading test output."
---
# Verification Report - 0000028-telemetry-hardening-and-enforcement-fixes

> Produced under REQ-005 and `planifest-verify-by-execution`. Every item below was confirmed by executing
> the software and observing a real side effect. Test-suite output alone does not appear as evidence here.

## REQ-005a: resolve-phase.mjs verified against a live hook firing (backlog 0000058)

**The open question.** `resolve-phase.mjs`'s `PreToolUse(Skill)` matcher and its `tool_input.skill` field
access had only ever been exercised by invoking the script directly. Backlog `0000058` was filed because no
live orchestrator session with a real Skill invocation was available when `0000027` shipped, so the matcher
and the field name were assumptions, not facts.

**Method.** After REQ-004 registered the hooks, the failure-marker directory was emptied so any new marker
could be attributed unambiguously. A real `Skill` tool call was then made in this live session
(`planifest-validate-agent`), and the resulting side effects were inspected directly.

**Evidence.**

| Observation | Result |
|-------------|--------|
| `.claude/.planifest-active-phase` | Contains `validate`, written 17:33 |
| Dedup flag in the real OS tmpdir | `phase-start-e905cb67-eee1-4e4b-b889-baa96ab4996a-validate`, written 17:33 |
| Session id in that flag | `e905cb67-eee1-4e4b-b889-baa96ab4996a`, this session's genuine id, not a fixture |
| Durable failure markers created | None |
| Backend query, scoped to this session id | `phase_start (1)` |

**Chain confirmed.** `PreToolUse(Skill)` fired, `resolve-phase.mjs` matched `tool_name === "Skill"`,
`extractSkillName()` read `tool_input.skill`, `PHASE_SKILLS` resolved `planifest-validate-agent` to the
`validate` phase, the active-phase marker was written, `emit-phase-start.mjs` was spawned, and the event
reached the backend with no failure marker.

**Verdict: the assumptions hold. No correction to the matcher or the field access is required.** Backlog
`0000058` is answered and can be closed.

**Incidental finding, not part of the acceptance criteria.** Three durable markers were found in
`plan/.telemetry-failures/` before the run, all `SyntaxError: Unexpected token 'o', "not json" is not valid
JSON`, `occurrences: 9`, spanning 12:48Z to 13:10Z. The literal payload `"not json"` is a test fixture
string, and the window matches this feature's own test runs. Tests are writing into the repository's real
marker directory rather than an isolated scratch workspace. Those markers were test pollution, not real
failures, and were cleared. Filed for pickup rather than fixed here, since it is a test-isolation defect
outside this feature's scope.

## REQ-005b: telemetry schema carries the loop and reversal fields (backlog 0000053)

**The open question.** Root Cause B of the `0000017` RCA was that the telemetry schema might be missing
entries for `loop_iteration` and `phase_reversal_*`. It has never been checked, because those events only
fire when a loop toggle or the reversal protocol is active, and none has been.

**Constraint on this run.** All loop toggles (`p0_completeness`, `design_critic`, `reversal_protocol`,
`cross_model_review`, `verify_by_execution`) are default off and none was enabled, so neither event class
could fire naturally.

**Method.** Rather than emit a synthetic event, which would insert a fabricated loop into the telemetry
store that build assessment later reads as real, the backend's own live contract was inspected. The
`emit_event` MCP tool's schema is that contract: it is what the backend accepts or rejects at ingestion.

**Evidence.** The `event` enum in the live `emit_event` schema contains all four types:

- `loop_iteration`
- `phase_reversal_petitioned`
- `phase_reversal_granted`
- `phase_reversal_denied`

The `data` field is typed `additionalProperties: {}`, so it imposes no constraint on payload shape. The
documented payloads in `telemetry-standards.md` (`loop_id`, `iteration`, `cap`, `decision`, `toggle_level`
for `loop_iteration`; `report`, `filing_phase`, `binding_artifact` for the reversal events) are therefore
accepted as written.

**Verdict: the schema carries the fields. Root Cause B of the 0000017 RCA is closed.** Backlog `0000053`
is answered.

**Stated limitation, so this is not read as more than it is.** This verifies that the backend accepts these
events at ingestion. It does not verify the end-to-end behaviour of a real loop or reversal, because none
ran. Confirming that a genuine loop emits well-formed events at the right points still requires a feature
that enables a toggle. That remains open, and is narrower than what `0000053` originally asked.

## REQ-004: install refresh and phase hook registration

**Method.** Ran `planifest-refresh-setup` end to end against the live install, with the flags reconstructed
from `.claude/.planifest-setup-flags` and confirmed by the human on the loop before any deletion.

**Evidence.**

| Observation | Result |
|-------------|--------|
| Boot file after `refresh-delete-boot-files.sh` | `CLAUDE.md` removed |
| Marker during the window | `attemptStatus: "pending"` with the exact attempted command recorded |
| `setup.sh` self-check | `telemetry hook presence check passed (4/4 hooks registered)` |
| Boot file after re-invocation | `CLAUDE.md` regenerated, 69 lines |
| Marker after completion | `attemptStatus: "completed"`, written by `setup.sh` itself |
| Shared modules installed | `read-stdin.mjs`, `phase-enum.mjs`, `em-dash-guard.mjs` present under `.claude/hooks/enforcement/` |

The session was interrupted between the deletion and the re-invocation. Recovery worked exactly as
`planifest-refresh-setup` Step 2 describes: the missing boot file plus `attemptStatus: "pending"` identified
the interrupted run, and the recorded `attemptedCommand` was re-run without repeating detection. That is an
unplanned but genuine live test of the recovery path, and it passed.

## REQ-001 and REQ-003: behaviour under failure

Verified by executing the hooks as real child processes against a controllable backend, with observed
timings rather than asserted ones. Full detail sits in the requirement docs and the test suite; the
headline results are that a never-listening backend yields exactly one marker and exit 0 at roughly 736ms,
a listener appearing mid-window delivers the event and writes no marker, and an HTTP 500 makes exactly one
attempt and is never retried.
