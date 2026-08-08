# Changelog (0000028-telemetry-hardening-and-enforcement-fixes, 08 Aug 2026)

**Feature:** Telemetry hardening and enforcement fixes
**Pipeline run:** P0 through P9 completed. No phases skipped.
**PR:** pending

## What Was Built

Planifest's telemetry hooks reported a routine, self-correcting backend restart as a hard failure, which
interrupted the human on the loop with a block-or-proceed decision about something that was never wrong.
That happened twice on the day this feature started: once in a downstream repository during feature
`0000018`, and once in this repository, halting this very run at P0 for a marker that turned out to be a
false positive.

This release narrows the definition of a telemetry failure, removes the duplication that forced every hook
fix to be applied several times over, registers the phase hooks that had never fired here, and adds a
deterministic style guard. Along the way P5 found that most of the framework's own enforcement hooks had
been silently dead on every bash install.

Six requirements delivered, nine backlog entries closed, one High security finding fixed and verified live.

## Artifacts Produced

`plan/current/` at archive time contained: `discovery.md`, `feature-brief.md`, `design.md`,
`execution-plan.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`, `operational-model.md`,
`slo-definitions.md`, `cost-model.md`, `security-report.md`, `verification-report.md`,
`recommendations.md`, `tech-debt.md`, `build-log.md`, six requirement documents under `requirements/`, and
four ADRs under `adr/`.

## Decisions

- **ADR-001, network-level retry semantics.** A telemetry emission failure is retried only when it is
  network-level, identified by `!err.name.startsWith("http_")`. An HTTP 4xx or 5xx means a listener answered
  and rejected the event deliberately, so it is never retried. Budget is 2 retries at fixed 300ms gaps, on
  top of the unchanged 3s per-attempt abort. Retry exhaustion still writes the durable marker, so a
  genuinely-down backend still surfaces. This narrows what counts as failure rather than adding a queue,
  which NFR-002 forbids.
- **ADR-002, shared module placement and install topology.** Helpers are extracted in place within
  `hooks/enforcement/` and `hooks/telemetry/` rather than into a new shared tree. The phase-enum module
  lives in `enforcement/` because that tree installs unconditionally while `telemetry/` installs only under
  `--structured-telemetry-mcp`; placing it in `telemetry/` would leave `check-telemetry-receipts.mjs`
  importing an absent file on most installs, crashing at module load before its own try/catch could run.
- **ADR-003, em dash guard attachment point and bypass.** A `PreToolUse(Write, Edit)` hook rather than a git
  hook or a P4 check, because both of those let the character reach disk first. The bypass is an in-content
  sentinel, deliberately unlike the human-only single-use `.ratchet-approve` marker, because an em dash
  carries no weakening semantics.
- **ADR-004, self-modification sequencing.** This feature edits the hooks running its own build, and because
  hooks must exit 0 on every path, a hook broken mid-edit degrades to a silent no-op rather than failing
  loudly. Callers are therefore rewired one at a time, each verified by its actual side effect rather than
  its exit code, with the next rewire blocked until the current one passes.

## Backlog Entries Closed

Delivered by this feature: `0000063` (retry), `0000054` and `0000057` (duplication), `0000058` and
`0000053` (live verification), `0000026` (style guard, scoped to the em dash only).

Closed without code, having been resolved already: `0000042`, verified as fixed in feature `0000026` with
only its entry status left stale; `0000051`, a pointer discharged by `0000020` being reviewed and
deliberately deferred; `0000052`, a pointer to `0000029` and `0000030`, both already actioned.

## Notable Findings

- **P5 SEC-001, High, fixed.** `setup.sh` wired every `hooks/enforcement/` hook as a bare `.mjs` path,
  relying on a shebang plus an executable bit that 9 of the 10 committed files did not carry. The wired
  command exited 126 and the hook silently never ran. Because a `PreToolUse` hook that fails to start is
  indistinguishable from one that passed, `gate-write`, `em-dash-guard`, `check-design`,
  `check-orchestrator-presence`, `auto-trigger-orchestrator` and both telemetry backstops were dead on every
  bash install. Fixed by invoking each hook through `node`, matching what `setup.ps1` and the context-mode
  hooks already did, and verified live in both directions.
- **A latent NFR-001 violation, fixed.** `readStdin()` lacked an stdin error handler in 10 of 12 hooks. The
  consolidation into one shared module fixed it everywhere at once.
- **Backlog `0000063` was right and P0 was wrong.** Discovery claimed five hooks carried the unretried-fetch
  defect. Only three call `fetch`. The P0 check grepped for the absence of a retry constant, which proves no
  retry exists but says nothing about whether a fetch does. Corrected at P1 and recorded in `design.md`.

## Skipped Phases

None.
