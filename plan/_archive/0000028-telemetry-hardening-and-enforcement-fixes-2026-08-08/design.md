# Design - 0000028-telemetry-hardening-and-enforcement-fixes

## Feature
- Problem: Planifest's telemetry hooks report a routine, self-correcting backend restart as a hard failure, interrupting the human on the loop with a block-or-proceed decision about something that was never wrong. The emit-and-record logic that must be fixed is duplicated across five hooks. Separately, artifact style rules are re-explained each session instead of being enforced.
- Adoption mode: standard-iterative
- Feature ID: 0000028-telemetry-hardening-and-enforcement-fixes
- Discovery: see `plan/current/discovery.md` (raw P0 findings; this document records confirmed decisions only)
- Version: 0.27.0 to 0.28.0 (minor, Feature Pipeline track)

## Product Layer
- User stories:
  - US-001: As a human on the loop, I want telemetry hooks to retry a network-level failure before recording it, so that a routine backend restart does not interrupt me with a failure that already self-corrected
  - US-002: As a framework maintainer, I want the duplicated emit-and-record logic extracted into one shared module, so that a fix to it is applied once instead of five times
  - US-003: As a framework maintainer, I want a failing marker write to leave a trace on stderr, so that a genuinely-down backend never produces zero signal
  - US-004: As a human on the loop, I want this repo's stale install refreshed so the phase telemetry hooks are registered, so that `phase_start` and `phase_end` are actually emitted
  - US-005: As a framework maintainer, I want `resolve-phase.mjs` verified against a live hook firing rather than direct invocation, so that its matcher and `tool_input` field assumptions are proven rather than assumed
  - US-006: As a human on the loop, I want a deterministic check that rejects em dashes in Planifest artifacts at write time, plus a one-off cleanup of existing live artifacts, so that the rule is enforced instead of re-explained
- Acceptance criteria confirmed: 11 (see `plan/current/feature-brief.md`)
- Constraints: dependency-free Node ESM, no `package.json` exists or may be introduced; hooks must never block the host session and must exit 0 on every path; no queue, buffer, or local fallback for undelivered telemetry; local git only
- Integrations: telemetry backend over HTTP POST `/emit` (external to this repo, not modifiable here)

## Architecture Layer
- Latency target: retry adds no more than 600ms worst case, on top of the existing 3s per-attempt abort
- Availability target: not applicable; hooks are short-lived local subprocesses
- Scalability target: not applicable
- Security: no auth surface introduced. Failure markers may echo user-configured URL and error strings verbatim, so they remain gitignored. Telemetry receipts are to be gitignored on the same reasoning.
- Data privacy: no regulated data. Markers and receipts are local-only and never committed.
- Observability: this feature is observability. New behaviour is one stderr line when a marker write fails.
- Cost boundary: not constrained

## Engineering Layer
- Stack: no frontend / Node ESM `.mjs` hooks plus bash and PowerShell setup / no database / no ORM / no IaC / no cloud / local subprocess compute / GitHub Actions CI / build target local
- Components:
  - `planifest-framework`: telemetry hooks, skills, templates, standards, tests. Owns all five hooks under `hooks/telemetry/` and `setup.sh` / `setup.ps1`.
  - `setup-hook-integration`: per-tool hook registration behaviour.
  - `context-mode-hooks`: `block-bash.mjs` and siblings. No code change this feature; `0000042` is a closure.
- Data ownership:
  - `plan/.telemetry-failures/` markers: `planifest-framework`; orchestrator reads at phase start
  - `plan/.telemetry-receipts/` receipts: `planifest-framework`; `check-telemetry-receipts.mjs` reads
  - Hook registration in tool settings: `setup-hook-integration`
- Deployment: not applicable. Changes take effect for a consumer on their next `setup.sh` run.
- API versioning: not applicable

## Scope
- In:
  - Bounded retry on network-level emission failures, in the three hooks that call `fetch` directly: `context-pressure`, `emit-phase-start`, `emit-phase-end`. `resolve-phase.mjs` makes no fetch call and delegates by spawning the emit hooks, so it inherits the fix transitively. `emit-event-receipt.mjs` writes a local file and has nothing to retry. Backlog `0000063`'s count of three was correct; the P0 discovery claim of five was an orchestrator error, corrected at P1 (see Corrections below).
  - Extraction of the duplicated logic into shared modules, wider than the two backlog entries describe: `readProductId()` in 3 hooks (`0000054`), the phase-enum maps (`0000057`), `recordTelemetryFailure()` in 4 hooks, the emit-and-record block in 3, `getFlagPath()` in 2, and `readStdin()` across 12 hooks. Consolidating `readStdin()` also fixes a latent NFR-001 violation: only `context-pressure.mjs` and `resolve-phase.mjs` wire `stdin.on("error")`, so the other ten hang on a stdin stream error instead of exiting 0.
  - Correction to `setup.sh:447`, where the tier-1 telemetry install globs `emit-phase-*.mjs` and would silently drop any new shared module, breaking the extraction for Cursor, Windsurf and Cline installs.
  - A stderr fallback line when a marker write itself fails, so the failure is never fully silent.
  - Gitignore entry for `plan/.telemetry-receipts/`, matching the existing `plan/.telemetry-failures/` treatment.
  - Refresh of this repo's stale install so the phase telemetry hooks are registered, then live verification of `resolve-phase.mjs` (`0000058`) and of the telemetry schema's `loop_iteration` and `phase_reversal_*` fields (`0000053`).
  - A deterministic em dash check at write time, plus a bounded one-off cleanup of existing live artifacts.
  - Closure of `0000042`, `0000051` and `0000052`, all of which resolve without new code.
- Out:
  - Backlog `0000020`, decomposition of the orchestrator skill. Ranked highest on value at P0 and deliberately excluded by the human on the loop as warranting a dedicated run with a populated regression pack.
  - Backlog `0000060`, `0000061`, `0000062`, reviewed at P0 and judged not valuable enough for this run.
  - Backlog `0000064`, Playwright MCP as a setup flag, filed during this P0.
  - New wiring code for the phase hooks. `setup.sh:626` `merge_telemetry_hook_settings()` already does this, shipped in `0000027`. This repo's `.claude/` install is simply stale, and `.claude/` is gitignored, so it is local machine state rather than repo state.
  - Any change to `block-bash.mjs`. The loopback fix shipped in `0000026` (`7f28593`).
  - Any queue, buffer, or local fallback for undelivered telemetry.
  - Retry on HTTP error status. A 4xx or 5xx means a listener answered and rejected the event, which is a real failure.
  - Em dash cleanup of `plan/_archive/` and `plan/changelog/`. Those are historical record; rewriting shipped artifacts to satisfy a rule introduced afterwards would falsify the audit trail.
  - Backlog `0000022` token accounting and `0000056` phase-completion signalling. Both become actionable once the phase hooks emit, and are candidates for the next run.
- Deferred:
  - The broader AI writing-tells list from `0000026` beyond the em dash. Needs its own decision on which artifacts are in scope. Nothing here is blocked by it.
  - Whether `0000042`'s loopback approach should generalise to `block-grep.mjs` and `block-webfetch.mjs`. To be assessed at P1; the other two hooks may not share the pattern.

## Corrections (P1)

Recorded per the framework's requirement that documentation match reality after any deviation.

- **Hook count for REQ-001.** P0 discovery asserted that five telemetry hooks carry the unretried-fetch defect and that backlog `0000063` understated it at three. That was wrong. The P0 check grepped for the absence of `RETRY_DELAYS_MS`, which establishes that no retry exists but says nothing about whether a `fetch` call exists. Direct inspection at P1 found `fetch` in exactly three hooks. `0000063`'s original count stands. Corrected in Scope above and in `feature-brief.md`.
- **Em dash cleanup volume.** P0 cited roughly 870 files from an unscoped repo-wide count. Scoped to live artifacts only, excluding `plan/_archive/` and `plan/changelog/`, the real figure is 99 files and 772 occurrences. The unscoped whole-repo count is 1,010 files. Corrected in REQ-006.
- **Duplication extent for REQ-002.** Backlog `0000054` and `0000057` together describe two duplicated helpers. P1 inspection found six, plus a latent NFR-001 violation in `readStdin()`. Scope widened accordingly, and `getSessionId()` was found to have three genuinely different behaviour profiles across its four copies, so it is explicitly excluded from consolidation as unsafe.

## Assumptions
- ~~The `--structured-telemetry-mcp` flag was passed for this install~~ **Resolved at P1, no longer an assumption.** `.claude/.planifest-setup-flags` records `["--context-mode-mcp","--structured-telemetry-mcp","--strict-orchestrator"]` with `backendUrl: http://localhost:3741`. REQ-004's precondition holds as verified fact.
- `resolve-phase.mjs`'s `PreToolUse(Skill)` matcher and `tool_input.skill` field assumption may be wrong, since neither has ever been observed firing - impact if wrong: US-005 becomes a fix rather than a verification, expanding P3.
- The downstream retry fix in `0000063` is a sound starting point, verified there against a controllable backend - impact if wrong: the 2 attempts at 300ms budget needs re-derivation, though the network-versus-HTTP distinction holds regardless.
- The one-off em dash cleanup can be applied mechanically to live artifacts without changing meaning - impact if wrong: a replacement alters the sense of a sentence, which P4 and P5 review must catch.

## Risks
- This feature edits the hooks that are running its own build. A half-applied shared-module extraction leaves a hook importing a module that does not exist yet, and because hooks must exit 0 on every path, it degrades to a silent no-op rather than a visible failure. Likelihood medium, impact high. Mitigation: create shared modules before rewiring any caller, and verify live rather than assuming.
- The em dash cleanup touches roughly 870 files. Likelihood high that some replacement is contextually wrong, impact medium. Mitigation: bound to live artifacts only, exclude archive and changelog, and review the diff at P4.
- `.claude/` being gitignored means the live hook install cannot be restored with `git checkout`, only by re-running setup. Likelihood low, impact medium. Mitigation: treat `planifest-framework/hooks/` as the sole source of truth and re-run setup to recover.
- Scope grew from four backlog entries to six requirements plus three closures, past the framework's own three-story heuristic. Likelihood of overrun medium, impact medium. Mitigation: the telemetry items are one coherent cluster over the same five files.

## Dependencies
- Upstream: telemetry backend on `PLANIFEST_TELEMETRY_URL` (verified healthy at P0: listener on `127.0.0.1:3741`, `POST /emit` answering); `0000027`'s `merge_telemetry_hook_settings()`; `0000026`'s `block-bash.mjs` loopback fix.
- Downstream: backlog `0000022` and `0000056` both unblock once phase events emit; downstream repos vendoring this framework pick the retry fix up on their next update, which retires the fragile local patch `structured-telemetry-mcp` currently carries.

## Active Skills
None installed for this run. `planifest-verify-by-execution` is loaded by the P4 validate-agent per its own skill. Playwright MCP was checked and is not available (absent from the session tool set and from the connector registry), and is filed as backlog `0000064`.

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 - bounded retry across five telemetry hooks | planifest-codegen-agent | TDD cycle over hook behaviour with a controllable backend |
| REQ-002 - shared module extraction | planifest-refactor | Behaviour-preserving restructure with tests already green |
| REQ-003 - stderr fallback on marker write failure | planifest-codegen-agent | Small additive branch in the shared record path |
| REQ-004 - install refresh and phase hook registration | planifest-refresh-setup | Purpose-built for reconstructing setup flags and re-running setup |
| REQ-005 - live verification of resolve-phase and schema | planifest-verify-by-execution | Requires observing real hook firing, not reading test output |
| REQ-006 - em dash write-time guard and cleanup | planifest-codegen-agent | New enforcement hook following the `commit-msg` precedent |

## Repo Instructions
From `planifest-overrides/instructions/`:

- `custom-001-local-git-only.md` - Local Git Only. Do not fetch, pull, push, or use remote git commands; commit to a local feature branch and let the human on the loop push and raise PRs. Exception only when the human expressly asks.
- `custom-002-prefer-subagent-decomposition.md` - Prefer Subagent Decomposition for Longer Tasks. Default to splitting long or multi-unit work across parallel subagents rather than working sequentially in one context; state the reason when a task genuinely cannot be split.
- `custom-003-git-up-to-date-shorthand.md` - Shorthand: GUTD. On the literal token `GUTD`, run git status first, checkout main, pull latest, and report untracked files rather than silently ignoring them.

Session directive from the human on the loop: use subagents throughout, run continuously, and leave no loose or untracked files by the end of the run.

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 08 Aug 2026 @ 01:28 PM BST
