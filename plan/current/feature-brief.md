---
title: "Feature Brief - telemetry-hardening-and-enforcement-fixes"
summary: "The business case, scope, and product requirements for the feature."
status: "draft"
version: "0.28.0"
---
# Feature Brief - telemetry-hardening-and-enforcement-fixes

**Feature ID:** 0000028-telemetry-hardening-and-enforcement-fixes

> Assembled by the orchestrator at P0 from backlog entries selected by the human on the loop,
> plus two findings surfaced by the P0 discovery pass. Confirmed by the human before P1.

## Business Goal

Planifest's telemetry hooks report routine, self-correcting events as hard failures, which interrupts the
human on the loop with a block-or-proceed decision about something that was never wrong. This happened twice
today: once in a downstream repo during feature `0000018`, and once in this repo, halting this very run at P0
for a marker that turned out to be a false positive. Separately, the P0 discovery pass established that four
telemetry hooks and one resolver are present on disk but registered against no hook event, so `phase_start`
and `phase_end` are not emitted here at all, which silently blocks four other backlog entries that depend on
those events firing.

This feature narrows the definition of a telemetry failure, wires the hooks that were never registered,
removes the duplication that forces every hook fix to be applied five times, and adds two enforcement fixes
that share the same character: a false positive that blocks legitimate work, and a style rule that is
currently re-discovered each session instead of being enforced.

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| Telemetry emit robustness | As a human on the loop, I want telemetry hooks to retry a network-level failure before recording it, so that a routine backend restart does not interrupt me with a failure that already self-corrected | must-have | 1 |
| Telemetry emit robustness | As a framework maintainer, I want the duplicated emit-and-record logic extracted into one shared module, so that a fix to it is applied once instead of five times | must-have | 1 |
| Phase hook registration | As a human on the loop, I want the phase telemetry hooks registered against real hook events, so that `phase_start` and `phase_end` are actually emitted for a pipeline run | must-have | 1 |
| Phase hook registration | As a framework maintainer, I want `resolve-phase.mjs` verified against a live hook firing rather than direct invocation, so that its matcher and `tool_input` field assumptions are proven rather than assumed | should-have | 1 |
| Enforcement false-positive fix | As an agent running a pipeline phase, I want the context-mode Bash hook to distinguish an outbound fetch from a local URL passed as an argument, so that legitimate commands are not blocked and worked around | should-have | 1 |
| Artifact style enforcement | As a human on the loop, I want a deterministic check that rejects em dashes in Planifest artifacts, so that the rule is enforced at write time instead of being re-explained every session | should-have | 1 |

## Waves

Single wave. Six stories across four features, all within one component boundary except the context-mode fix.

| Wave | Features Included | Ships When |
|------|-------------------|------------|
| 1 | All four | P9 |

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| `planifest-framework` | component-pack | existing | Telemetry hooks, skills, standards, templates, tests |
| `setup-hook-integration` | component-pack | existing | `setup.sh` / `setup.ps1` and per-tool hook registration |
| `context-mode-hooks` | component-pack | existing | `block-bash.mjs`, `block-grep.mjs`, `block-webfetch.mjs` |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| `plan/.telemetry-failures/` markers | `planifest-framework` | orchestrator reads at phase start |
| `plan/.telemetry-receipts/` receipts | `planifest-framework` | `check-telemetry-receipts.mjs` reads |
| Hook registration in tool settings | `setup-hook-integration` | all hooks are registered by it |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| telemetry hooks | telemetry backend | HTTP POST `/emit` | Event envelope per `telemetry-standards.md` |
| `setup-hook-integration` | tool settings file | file write | Hook event, matcher, command |
| `resolve-phase.mjs` | `emit-phase-start.mjs` | process invocation | Phase argument |

## Stack

| Concern | Decision |
|---------|----------|
| Language | JavaScript (Node ESM, `.mjs`), plus bash and PowerShell for setup |
| Runtime | Node.js, invoked directly by the host tool; no package manager, no `package.json` anywhere in the repo |
| Framework | none, dependency-free by deliberate convention |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | Shell and `.mjs` test scripts under `planifest-framework/tests/`, driven by `run-tests.sh` |
| IaC | none |
| Cloud | none |
| Compute | local, hooks run as short-lived subprocesses of the host tool |
| CI | GitHub Actions |
| Build target | local |

## Scope Boundaries

### In Scope

- Bounded retry on network-level emission failures, in the three hooks that call `fetch` directly:
  `context-pressure`, `emit-phase-start`, `emit-phase-end`. `resolve-phase.mjs` makes no fetch call and
  delegates by spawning the emit hooks, so it inherits the fix. `emit-event-receipt.mjs` writes a local file
  and has nothing to retry. Backlog `0000063`'s count of three was correct; the P0 claim of five was an
  orchestrator error corrected at P1.
- Extraction of the duplicated logic into shared modules: `readProductId()` (`0000054`), the phase-enum maps
  (`0000057`), `recordTelemetryFailure()`, the emit-and-record block, `getFlagPath()`, and `readStdin()`.
  Consolidating `readStdin()` also fixes a latent NFR-001 violation, since only two of twelve hooks wire
  `stdin.on("error")` and the rest hang on a stdin stream error instead of exiting 0. `getSessionId()` is
  excluded from consolidation: its four copies have three genuinely different behaviour profiles.
- Correction to `setup.sh:447`, where the tier-1 telemetry install glob would silently drop a shared module.
- Registration of the phase telemetry hooks so `phase_start` and `phase_end` are emitted.
- Live verification of `resolve-phase.mjs` against a real hook firing (`0000058`).
- Verification that the telemetry schema carries `loop_iteration` and `phase_reversal_*` fields (`0000053`).
- A narrower Bash pattern in `block-bash.mjs` distinguishing an outbound fetch from a URL-shaped argument,
  with `http://localhost` and `127.0.0.1` targets never treated as outbound (`0000042`).
- A deterministic em dash check over Planifest artifacts, following the `commit-msg` hook precedent
  (`0000026`, scoped hard).
- Closure of `0000051` and `0000052`, both of which are pointers that resolve without code.

### Out of Scope

- Backlog `0000020`, decomposition of the orchestrator skill. Ranked highest on value at P0 and deliberately
  excluded by the human on the loop as warranting a dedicated run with a populated regression pack.
- Backlog `0000060`, `0000061` and `0000062`, reviewed at P0 and judged not valuable enough for this run.
- The broader AI writing-tells list from `0000026`. Only the em dash check is in scope; the rest is deferred.
- Backlog `0000022` token accounting and `0000056` phase-completion signalling. Both become actionable once
  this feature wires the phase hooks, and are candidates for the next run.
- Any queue, buffer, or local fallback for undelivered telemetry. A failure is still dropped and still
  recorded via the durable marker. Only the definition of failure narrows.
- Retry on HTTP error status. A 4xx or 5xx means a listener answered and rejected the event, which is a real
  failure, not a listener gap.
- Backlog `0000064`, Playwright MCP as a setup flag, filed during this P0 and deferred.

### Deferred

- The broader writing-tells list beyond the em dash, which needs its own decision on which artifacts are in
  scope and whether enforcement is a hook or instruction-only. Nothing in this feature is blocked by it.
- Whether `0000042`'s fix generalises to `block-grep.mjs` and `block-webfetch.mjs`. To be decided at P1 once
  the false-positive class is characterised; the other two hooks may not share the pattern.

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Hook latency | Retry adds no more than 600ms worst case, on top of the existing 3s per-attempt abort | Timed hook invocation against a backend that never listens |
| Session safety | Every hook exits 0 on every path, including retry exhaustion | Existing NFR-001, asserted by test |
| No local fallback | No queue, buffer, or deferred delivery is introduced | Existing NFR-002, asserted by code review at P5 |
| Failure fidelity | A backend that is genuinely down still produces exactly one durable marker | Test with no listener present throughout |
| False-positive rate | A listener appearing mid-retry produces no marker and delivers the event | Test with a listener bound partway through the retry window |

## Constraints and Assumptions

### Constraints

- Dependency-free. No `package.json` exists and none is to be introduced; shared modules are plain `.mjs`
  imported by relative path.
- Hooks must never block the host session, on any path, including unexpected errors.
- The telemetry backend is external to this repo. It cannot be modified here.
- Local git only. No fetch, pull, or push except where the human on the loop expressly asks.

### Assumptions

- The `--structured-telemetry-mcp` setup flag was passed for this install, inferred from the backend URL
  being hard-coded into the one registered hook. If that inference is wrong, the phase-hook registration
  requirement changes shape and must be re-specified.
- The downstream retry fix in `0000063` is a sound starting point, having been verified there against a
  controllable backend, but its 2 attempts at 300ms is a starting budget rather than a settled decision.
- `resolve-phase.mjs`'s `PreToolUse(Skill)` matcher and `tool_input.skill` field assumption may be wrong,
  since neither has ever been observed firing. `0000058` exists precisely because this is unverified.

## Scenario Paths

Drafted in parallel by four `planifest-scope-lock-agent` instances at P0, then accepted item by item by the
human on the loop. All four accepted as drafted.

**Happy path:**

> The feature is invisible when it works. As the pipeline moves between phases, each transition produces a
> matching `phase_start` and `phase_end` event, which this repo has never emitted before. When a hook sends
> an event and the backend is up, it is delivered on the first attempt exactly as today. When the backend is
> caught in the brief window of a restart, the hook waits and retries, the event still arrives, and nothing
> is recorded as failed. Success looks like silence: no interruption, no marker, and no block-or-proceed
> question at the next phase boundary for something that was never broken. Artifacts never land containing
> an em dash, because the check catches it at write time rather than the human on the loop noticing later.

**First-run path:**

> Nothing prior needs to exist. `plan/.telemetry-failures/` and `plan/.telemetry-receipts/` are created on
> demand the first time something needs writing, and their absence is not an error; anything reading receipts
> treats a missing directory the same as an empty one. Phase events have no history to reconcile against,
> because the very first transition after this feature lands is also the first phase telemetry this repo has
> ever emitted. The em dash hook inspects only the content being written in that moment and never
> retroactively scans, matching the `commit-msg` precedent. Existing live artifacts are handled instead by a
> separate, bounded one-off cleanup pass, deliberately excluding `plan/_archive/` and `plan/changelog/`.

**Error / sad path:**

> Seven distinct failure modes, in three buckets. Retried and invisible: a backend mid-restart, where a
> listener appearing inside the retry budget means the event is delivered and no marker is written. Recorded
> and surfaced exactly once: a backend that never listens, a 4xx or 5xx response, and retry exhaustion. An
> HTTP error status is never retried, because a listener answered and rejected the event deliberately, which
> is a real failure rather than a listener gap. Newly addressed: a failing marker write, which currently
> produces zero signal, now emits one stderr line so a genuinely-down backend never vanishes without trace.
> Every path still exits 0 and never blocks the session. A shared-module defect that trips only one hook
> leaves the other four working, and is caught by that hook's own test coverage rather than by any runtime
> cross-check. The em dash check rejects flatly with a stated bypass rather than judging intent.

**Cross-session continuity:**

> Durable regardless of when an interruption lands: the markers under `plan/.telemetry-failures/`, written
> straight to disk independent of any commit and carrying occurrence counts plus first-seen and last-seen
> timestamps, so a repeat across a resume increments rather than resets. Also durable: `build-log.md`,
> committed under the commit-after-every-artifact discipline, which a resumed session reads to reconstruct
> what was actually recorded rather than what was intended. At risk is whatever was written to
> `plan/current/` since the last commit; it still exists on disk but is not part of the history a resumed
> session trusts, so it needs a deliberate look at working-tree state. The sharper risk is specific to this
> feature: it edits the hooks running its own build, and because hooks must exit 0 on every path, a
> half-applied extraction degrades to a silent no-op rather than a visible failure. Shared modules are
> therefore created before any caller is rewired, and a hook found broken mid-run is fixed forward and
> verified live rather than assumed working. Recovery is asymmetric: `planifest-framework/hooks/` is tracked
> and recovers via git, while the live install under `.claude/` is gitignored and can only be restored by
> re-running setup.

## Acceptance Criteria

- [ ] All five telemetry hooks retry a network-level failure and do not retry an HTTP error status.
- [ ] A backend that never listens still produces exactly one durable marker, and the hook exits 0.
- [ ] A backend that starts listening partway through the retry window delivers the event and produces no marker.
- [ ] The emit-and-record logic, `readProductId()`, and the phase-enum maps each exist in exactly one place.
- [ ] `phase_start` and `phase_end` are emitted for a real pipeline phase transition in this repo.
- [ ] `resolve-phase.mjs` is observed firing from a live hook event, not direct invocation, and its matcher
      and field assumptions are confirmed or corrected against what actually fires.
- [ ] The telemetry schema carries `loop_iteration` and `phase_reversal_*` fields, or the gap is recorded.
- [ ] A Bash command carrying `http://localhost` as an argument to a local script is not blocked, while a
      genuine outbound fetch still is.
- [ ] An em dash in a Planifest artifact is rejected deterministically, with a stated bypass path.
- [ ] `0000051` and `0000052` are closed with their resolution recorded.
- [ ] No loose or untracked files remain at the end of the run.
