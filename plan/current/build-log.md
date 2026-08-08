---
title: "Build Log - 0000028-telemetry-hardening-and-enforcement-fixes"
summary: "Working telemetry file maintained by the orchestrator throughout the pipeline run."
---
# Build Log - 0000028-telemetry-hardening-and-enforcement-fixes

> Created at P0. Appended by the orchestrator at each phase boundary. Survives session changes.

## Header

| Field | Value |
|-------|-------|
| Feature ID | `0000028-telemetry-hardening-and-enforcement-fixes` |
| Pipeline start | `2026-08-08T11:30:00Z` |
| Tool | `Claude Code` |
| Primary model | `claude-opus-5` |
| Cheaper model | `claude-sonnet-5` |

---

## Phase Log

### P0: Assess & Coach

| Field | Value |
|-------|-------|
| Start | `2026-08-08T11:30:00Z` |
| Model tier | primary |
| Skills loaded | planifest-orchestrator |
| Agents spawned | `0` |
| MCP calls | `9` |
| Parallel task batches | `0` |
| Telemetry | failed-with-recorded-choice |
| Notes | See P0 exchange trail below. |

Adoption mode: standard-iterative, detected from `plan/_archive/` (28 prior features) plus `docs/about.md`; confirmation pending with the human on the loop.

Telemetry: a durable failure marker `context-pressure--TypeError--fetch-failed.json` (root cause key
`context-pressure::TypeError::fetch-failed`, 4 occurrences, 2026-08-08T09:10:28Z to 09:11:55Z) was present
at P0 start. The human on the loop chose **block until resolved**. Investigation established the marker as a
false positive matching backlog `0000063` exactly: the incident window it documents (09:10:25Z to 09:15:53Z)
contains this marker's whole lifetime, and the backend was verified healthy at P0 (listener on 127.0.0.1:3741,
`POST /emit` answering HTTP 400 to a deliberately malformed probe body). Block discharged on that evidence.
Marker cleared with the agreement of the human on the loop. The underlying defect stays open as `0000063`
and is in scope for this feature. Root cause `context-pressure::TypeError::fetch-failed` is acknowledged for
the remainder of this run and will not be re-asked.

### P1: Requirements

| Field | Value |
|-------|-------|
| Start | `2026-08-08T12:30:00Z` |
| Model tier | primary, with cheaper-tier subagents for per-requirement drafting |
| Skills loaded | planifest-spec-agent |
| Agents spawned | `6` |
| MCP calls | `3` |
| Parallel task batches | `1` |
| Telemetry | confirmed-disabled |
| Notes | Six requirements plus supporting artifacts, drafted across one batch of six parallel subagents. Three P0 corrections and two newly found defects, detailed below. |

Telemetry: the unified signal is active per `.claude/.planifest-setup-flags`, but the phase hooks are not
registered in this install, which is precisely what REQ-004 fixes. No `phase_start` or `phase_end` could be
emitted for P1. Recorded as `confirmed-disabled` rather than `emitted`, since claiming emission that did not
happen is the failure mode `check-telemetry-receipts.mjs` exists to catch. Expected to become `emitted` from
the phase following REQ-004.

P1 corrections to P0 (documentation must match reality):
- REQ-001 covers three hooks, not five. The P0 check grepped for the absence of `RETRY_DELAYS_MS`, which
  proves no retry exists but says nothing about whether a `fetch` does. Backlog `0000063` was right.
- Em dash cleanup is 99 live files and 772 occurrences, not the roughly 870 from an unscoped count.
- REQ-002 duplication is six helpers, not the two named by backlog `0000054` and `0000057`.

Defects found while specifying, folded into REQ-002 rather than filed separately:
- `readStdin()` has no stdin error handler in 10 of 12 hooks, so they hang rather than exit 0 on a stdin
  stream error. This violates NFR-001 in the code today.
- `setup.sh:447` globs `emit-phase-*.mjs` for tier-1 telemetry installs and would silently drop a shared
  module for Cursor, Windsurf and Cline.

### P2: Architecture Decisions

| Field | Value |
|-------|-------|
| Start | `2026-08-08T12:45:00Z` |
| Model tier | primary, with cheaper-tier subagents per ADR |
| Skills loaded | planifest-adr-agent |
| Agents spawned | `4` |
| MCP calls | `0` |
| Parallel task batches | `1` |
| Telemetry | confirmed-disabled |
| Notes | Four ADRs drafted in one parallel batch. ADR-002 corrected a premise: neither `check-telemetry-receipts.mjs` nor `resolve-phase.mjs` currently imports a phase-enum module, so the placement decision is forward-looking rather than a fix to an existing crash. |

### P3: Code Generation

| Field | Value |
|-------|-------|
| Start | `2026-08-08T12:55:00Z` |
| Model tier | primary for the sequential extraction, cheaper-tier subagents for independent work |
| Skills loaded | planifest-codegen-agent, planifest-test-writer, planifest-implementer, planifest-refactor |
| Agents spawned | `4` |
| MCP calls | `6` |
| Parallel task batches | `2` |
| Telemetry | emitted |
| Notes | Parallelism constrained by ADR-004: REQ-002's extraction rewires one caller at a time with live verification between steps, because a hook broken mid-edit exits 0 and degrades to a silent no-op. REQ-006 is independent and runs in parallel. |

### P4: Validate

| Field | Value |
|-------|-------|
| Start | `2026-08-08T17:40:00Z` |
| Model tier | primary |
| Skills loaded | planifest-validate-agent, planifest-verify-by-execution |
| Agents spawned | `0` |
| MCP calls | `4` |
| Parallel task batches | `0` |
| Telemetry | emitted |
| Notes | CI green on the first full run after P3's repairs. No self-correction cycles were needed for the suite itself. |

CI result: 56 feature suites and 22 regression tests, all passing, working tree clean.

Semantic traceability found a real gap that raw counts hid. Grepping for `req-001:` through `req-006:`
returned healthy-looking numbers only because those ids collide with every prior feature's requirement
numbering. Scoped to this feature's own test files, REQ-004 and REQ-005 had no automated coverage at all.

REQ-005 remains uncovered by automated test, deliberately and on the record. It asserts a live hook firing,
which no test can reproduce without a real host tool session. That is precisely why backlog `0000058`
existed, and its evidence is the observed run in `plan/current/verification-report.md` rather than a suite
result. REQ-004 had genuinely assertable surface, so
`test-0000028-req-004-install-refresh-registration.sh` was added to close it.

### P5: Security

| Field | Value |
|-------|-------|
| Start | `2026-08-08T18:05:00Z` |
| Model tier | primary |
| Skills loaded | planifest-security-agent |
| Agents spawned | `1` |
| MCP calls | `2` |
| Parallel task batches | `0` |
| Telemetry | emitted |
| Notes | One High finding, fixed and verified live in the same phase. Remaining findings Low or Informational. |

Overall rating High, driven entirely by SEC-001. No exploitable vulnerability was found anywhere in the
change.

SEC-001: `setup.sh` wired every `hooks/enforcement/` hook into `settings.json` as a bare `.mjs` path,
relying on the shebang plus an executable bit. That bit is a committed file mode, and 9 of the 10 hook files
are mode 100644, so the shell could not exec them. The wired command exited 126 and the hook silently never
ran. Because a PreToolUse hook that fails to start is indistinguishable from one that passed, this was
invisible. Dead on every bash install: `gate-write`, `em-dash-guard`, `check-design`,
`check-orchestrator-presence`, `auto-trigger-orchestrator` and both telemetry backstops. `ratchet-check`
worked only because it happens to be committed executable, and the context-mode hooks worked because they
were already wired through `node`.

The finding was reproduced before being fixed (exit 126 as wired, exit 0 through `node`). It also explains
why em dashes kept landing in this very build log unchallenged during the run: REQ-006 was not satisfied in
the installed state. Fixed by invoking each hook through `node`, matching what `setup.ps1` and the
context-mode hooks already did. Verified live in both directions after re-running setup: a Write containing
an em dash is now blocked, and a clean Write still succeeds.

The suite could not have caught this, because every test invokes hooks via `node` directly rather than
through the command string `setup.sh` writes. Assertions were added against the wiring itself, plus a
pattern guard so a bare-path wiring cannot be reintroduced for any enforcement hook added later.

Remaining findings, accepted rather than fixed: SEC-002, the new stderr line prints a marker path whose slug
can contain a fragment of a malformed backend URL, the same content as the already-gitignored filename.
SEC-003, the true worst-case retry wall time is 9.6s rather than the 600ms stated in R-007, since each of
the three attempts owns its own 3s abort. SEC-004, `AbortError` is not excluded from the retry predicate, so
a slow-but-live backend can receive the same envelope up to three times, mitigated by the envelope being
byte-identical and therefore naturally dedupable. SEC-005, the bypass sentinel matches anywhere in content,
so a document explaining the rule exempts itself.

The headline check came back clean. The REQ-002 refactor did not weaken the CWE-22 path-traversal guard in
`emit-event-receipt.mjs`: `PHASE_ENUM` carries the same seven values as the inline set literal it replaced,
`KNOWN_PHASES` is still consulted, and the reject branch still throws before the `join()`.

### P6: Documentation

| Field | Value |
|-------|-------|
| Start | `2026-08-08T18:00:00Z` |
| Model tier | primary |
| Skills loaded | planifest-docs-agent |
| Agents spawned | `0` |
| MCP calls | `0` |
| Parallel task batches | `0` |
| Telemetry | emitted |
| Notes | Gate A passed. Gate B auto-accepted under continuous run. Version set to 0.28.0 across `planifest-framework/component.yml`, `product.yml` and `docs/about.md`, confirmed by `product-version.mjs` deriving 0.28.0. Four living docs updated, `recommendations.md` produced, 8 backlog entries filed, 9 closed. Four drift findings flagged rather than silently fixed. |

**P6 Gate B: docs update assessment (continuous run, auto-accepted).**
This run changed the hook module topology (first intra-component module dependency, including two cross-directory edges), added a new enforcement hook, narrowed the definition of a telemetry emission failure, and fixed a wiring defect that had left seven enforcement hooks inert.
Auto-accepted: updating `docs/component-registry.md`, `docs/dependency-graph.md`, `docs/architecture-overview.md` and `docs/decisions-index.md`. No update needed for `docs/api-index.md`, which does not exist and should not: no component exposes an API, and `design.md`'s Engineering Layer declares no frontend, no database, no cloud and no IaC.

Drift found and flagged rather than fixed, recorded in `recommendations.md`:
- `scope.md`'s first In Scope bullet still reads "all five telemetry hooks" for REQ-001 and names `emit-event-receipt.mjs` and `resolve-phase.mjs` among them. P1 corrected this to three everywhere else, including `design.md`'s own Corrections section, which records the fix as applied "in Scope above" (its own section) while `scope.md` went untouched. REC-010.
- This build log has no P4 and no P5 phase block, though both phases ran and produced `verification-report.md`, `security-report.md`, three test repairs and the SEC-001 fix. Hard Limit 8 requires a block at every phase. REC-009, and it should be reconstructed before P7 archives this file.
- `docs/decisions-index.md`'s "Last updated" read `0000025`, three features stale, while entries for `0000026` and `0000027` were present in the body. Advanced to this feature.
- `src/setup-hook-integration/docs/interface-contract.md`'s outputs table named the context-mode hooks as `.sh` (they became `.mjs` at 0000017) and described telemetry installation as requiring both flags (0000018-ADR-001 removed the AND-condition). Corrected in place with the corrections marked inline, since the table also had to be updated for this feature's shared modules.
- This feature's four ADR files were written as `0000028-ADR-00N-{slug}.md`, against the convention `plan/current/adr/ADR-{NNN}-{title}.md` that `planifest-adr-agent`'s SKILL.md states and all 27 prior features follow. The consequence was not cosmetic: `consistency-check.mjs` anchors its ADR resolution on `^(ADR-\d{3})`, so every one of this feature's ADRs was reported as a dangling reference, 8 findings of pure noise. Renamed to conform, and the one path-style reference in `security-report.md` updated. Findings dropped from 18 to 10.
- `consistency-check.mjs` reports all 6 requirements over its stated cap of 3 acceptance criteria (10, 8, 8, 7, 6, 5). Real rule violations from P1, flagged rather than acted on: splitting requirements at P6 would be worse than the violation. The reason nobody saw them is that the script only runs under the design-critic loop, which is toggled off. REC-014.
- The 4 remaining `references ADR-005 but no such file exists` findings are false positives. `ADR-005` is `0000003-ADR-005`, the fail-open convention every hook in this repo follows; the checker cannot express a cross-feature reference. REC-015.

Artifact completeness check against 0000027-ADR-004's minimal Phase 1 set: execution plan, requirements, scope, risk register and domain glossary all present. Operational Model, SLO Definitions and Cost Model are present too, above the minimum. No OpenAPI specification, correctly: no component exposes an API. No per-component `docs/` directory exists for `planifest-framework`, which is the component this feature actually changed, because it sits at the repo root rather than under `src/`; its documentation lives in `component.yml` and the living docs instead. Noted rather than left as a silent gap; backlog `0000061` and `0000062` govern that structural question and both were deliberately left at P0.

Gate accepted: P0 at 2026-08-08T12:28:00Z

---

## P0 Audit Trail

P0 exchange, git sync (GUTD): Q: Are all previous PRs merged and is main up to date? / A: Human invoked the
GUTD shorthand. `git fetch origin` succeeded; `git rev-list --left-right --count origin/main...main` returned
`0	0`, so local main was identical to origin/main at `abe130f` (PR #54). No pull needed, no divergence, no
local-only commits. Untracked backlog entries reported.

P0 exchange, telemetry block-or-proceed: Q: Telemetry emission failed (TypeError / fetch failed, hook
context-pressure, 4 occurrences). Block until resolved, or proceed without telemetry? / A: Block until
resolved. Resolved by investigation as recorded in the P0 phase block above.

P0 exchange, feature subject: Q: What are we building? `plan/current/` is empty and there is no feature
brief. / A: A batch of fixes drawn from `plan/backlog/`, starting with the telemetry defect just diagnosed.

P0 exchange, backlog exploration: Q: 21 entries are open. Which form this release? / A: Human asked for the
backlog to be walked through and ranked. Group B (`0000060`, `0000061`, `0000062`) was reviewed and rejected
as not valuable enough for this run; `0000063` accepted.

P0 exchange, scope confirmation: Q: Take the recommended set (`0000063` + phase-hook wiring + `0000054` +
`0000057` + `0000051`/`0000052` closures), or promote `0000020` and make this the decomposition release? /
A: Recommendation agreed, `0000020` explicitly excluded, and four further entries requested.

P0 exchange, scope additions: Q: Which four additions? Recommended `0000058`, `0000053`, `0000042`,
`0000026`, with `0000026` scoped hard at P1 to a single deterministic em dash check and the broader
writing-tells list deferred. / A: Confirmed.

P0 exchange, Playwright MCP: Q: Is Playwright MCP available, and can it be incorporated as a setup flag? /
A: Checked and not available. Absent from this session's tool set, and a connector-registry search for
`playwright`, `browser automation`, `e2e testing` and `web testing` returned zero results. Filed as backlog
`0000064` rather than scoped into this feature.

P0 exchange, run mode: Q: Review after each phase, or continuous run? / A: Continuous, with subagents used
throughout. Recorded in `plan/.run-mode`. The P0 design gate and the Scope Lock per-item accepts are retained,
since continuous mode waives the P1 to P6 phase gates only.

P0 exchange, scope collapse: Q: Two Scope Lock agents flagged that `0000042` and the phase-hook wiring may
already be done. Verified both against the repo. `block-bash.mjs` already carries the loopback exemption
(`LOOPBACK_HOSTS`, line 72), shipped in `7f28593` under feature `0000026`, so `0000042` is fixed but its entry
still reads `status: open`. `setup.sh:626` `merge_telemetry_hook_settings()` already wires `resolve-phase.mjs`
to `PreToolUse` and `Stop`, shipped in `0000027`, and `.gitignore:2` ignores `.claude/` wholesale, so the
settings file inspected at P0 is untracked local machine state rather than repo state. Confirm the revised
scope? / A: Confirmed. `0000042` drops to a closure and the wiring requirement becomes an install refresh.

P0 exchange, em dash scope: Q: Write-time only, write-time plus one-off cleanup, or repo-wide CI scan? The
repo already contains em dashes in roughly 870 files. / A: Write-time plus one-off cleanup. The orchestrator
bounded the cleanup to live artifacts (`plan/current/`, `docs/`, `planifest-framework/`) and excluded
`plan/_archive/` and `plan/changelog/` as historical record, stated to the human on the loop as a judgement
call open to reversal.

P0 exchange, telemetry receipts: Q: `plan/.telemetry-receipts/` is not gitignored, unlike its sibling
`plan/.telemetry-failures/`, so receipts would appear as untracked files. Gitignore or commit? / A: Gitignore.

P0 exchange, marker write silence: Q: A failing marker write currently produces no marker, no interrupt and
no trace. Address it here or defer? / A: Add a stderr fallback line. Still exits 0, still never blocks.

P0 exchange, design confirmation and push grant: Q: Confirm the design and I run P1 to P9 without stopping? /
A: Confirmed at 08 Aug 2026 @ 01:28 PM BST. The human on the loop additionally granted express authorisation
to push continually and to raise the pull request at the end.

**Remote push grant (Hard Limit 7, per-session):** granted expressly by the human on the loop on
2026-08-08. This is the stated exception to `planifest-overrides/instructions/custom-001-local-git-only.md`,
which otherwise forbids fetch, pull and push. Scope of the grant: push the feature branch
`feat/0000028-telemetry-hardening-and-enforcement-fixes` after each phase-gate commit, and raise the pull
request at P9. Not in scope: pushing `main`, which is currently one commit ahead of `origin/main` at
`2e32f31` from the human's own work and is theirs to push. A failed push is reported once and never blocks
the pipeline.

---

## Scope Lock Challenge (P0, ADR-003 default parallel dispatch)

Four `planifest-scope-lock-agent` instances dispatched in parallel, one per scenario path, before any question
was presented. All four returned drafts. Presented as a batch; the human on the loop gave a separate explicit
accept for each of the four.

Scope Lock, happy path: The feature is invisible when it works. Phase transitions emit `phase_start` and
`phase_end` for the first time in this repo, a backend caught mid-restart receives the event on retry with no
marker and no interrupt, and artifacts never land containing an em dash. [source: agent-draft-accepted]

Scope Lock, first-run path: `plan/.telemetry-failures/` and `plan/.telemetry-receipts/` are created on demand
rather than pre-seeded, phase events have no prior history to reconcile against, and the em dash hook inspects
only content being written now while the one-off cleanup handles existing live artifacts as a separate bounded
pass. [source: agent-draft-accepted]

Scope Lock, error path: Mid-restart is retried and invisible. Never-listening, 4xx/5xx and retry exhaustion
are recorded as exactly one marker and surfaced once. A failing marker write now emits a stderr line rather
than vanishing silently. [source: agent-draft-accepted]

Scope Lock, cross-session continuity: Markers and `build-log.md` are durable, uncommitted `plan/current/`
work is at risk but recoverable by hand, and the sharp risk is this feature editing the hooks running its own
build, where a half-applied extraction degrades to a silent no-op because hooks must exit 0. Broken hooks are
fixed forward and verified live, never assumed working. [source: agent-draft-accepted]

Scope Lock complete. All four scenario paths captured.

Agent-surfaced flags carried into the design rather than resolved by the drafting agents: `0000042` already
shipped; the phase-hook wiring already exists in `setup.sh`; roughly 870 existing files contain em dashes;
`plan/.telemetry-receipts/` is not gitignored; the marker write failure path is silent; the em dash bypass
mechanism needs specifying for a Write/Edit hook since `--no-verify` has no equivalent there.

---

## Backlog Pickup (P0 step 3c)

| Entry | Decision |
|-------|----------|
| `0000063-telemetry-hooks-mark-daemon-restart-as-failure` | pull-in |
| `0000054-dedupe-read-product-id-helper` | pull-in |
| `0000057-consolidate-phase-enum-maps` | pull-in |
| `0000058-verify-resolve-phase-live-hook-firing` | pull-in |
| `0000053-telemetry-schema-missing-loop-reversal-fields` | pull-in |
| `0000042-context-mode-hook-false-flags-local-http-url-in-args` | pull-in as closure only: verified already fixed in `0000026` (`7f28593`), entry status never updated |
| `0000026-ai-writing-tells-style-guard` | pull-in (scoped hard at P1) |
| `0000051-orchestrator-router-decomposition-followup` | pull-in as closure only |
| `0000052-scope-lock-and-marker-commit-followups` | pull-in as closure only |
| `0000020-decompose-orchestrator-skill` | leave: explicitly excluded by the human on the loop; warrants a dedicated run |
| `0000060-p7-crossref-check-cannot-detect-relative-link-breakage` | leave |
| `0000061-component-manifest-path-inconsistent-with-framework-self-manifest` | leave |
| `0000062-no-lightweight-track-for-projects-without-src-components` | leave |
| `0000022-add-token-accounting-per-phase` | leave: unblocked by this feature's wiring work; candidate for the next run |
| `0000056-orchestrator-explicit-phase-completion-signal` | leave: same |
| `0000059-clarify-agent-vs-human-pronouns-in-choice-prompts` | leave |
| `0000050-verify-setup-flags-marker-live-pwsh` | leave |
| `0000025-declare-adoption-position-and-stability-policy` | leave |
| `0000023-publish-baseline-comparison` | leave |
| `0000026-ai-writing-tells-style-guard` | (listed above) |
| `0000048-loop-designer-meta-skill` | leave: blocked on loop evidence from two real features |
| `0000049-cross-vendor-critique-automation-p1-p2` | leave: blocked on per-project model-access configuration |

Notes on the two closure-only entries:

- `0000051` asks the next P0 to confirm `0000020` is still open and prioritise it. Done: `0000020` is open,
  was ranked first on value, and was excluded by the human on the loop as warranting its own run. `0000051`
  is discharged by that decision being recorded here.
- `0000052` asks whether backlog `0000029` and `0000030` are still open. Neither is present in
  `plan/backlog/`; both are referenced in the changelogs for `0000022` and `0000026`, indicating they were
  actioned. `0000052` is discharged as stale.

---

## Summary (filled at P7)

| Metric | Value |
|--------|-------|
| Total phases completed | `{{count}}` |
| Total agents spawned | `{{count}}` |
| Total MCP calls | `{{count}}` |
| Phases using parallelism | `{{count}}` |
| Primary tier agent calls | `{{count}}` |
| Cheaper tier agent calls | `{{count}}` |
| Self-corrections | `{{count}}` |
| Phases skipped | `{{list or "none"}}` |
| Phases with a recorded telemetry gap | `{{count}}` |

## P3 Outcomes

REQ-001, REQ-002, REQ-003 and REQ-006 delivered in two parallel subagent batches. REQ-004 and REQ-005 ran
sequentially, since REQ-005 cannot observe anything until REQ-004 registers the hooks.

Telemetry became live during this phase. REQ-004's install refresh registered the phase hooks for the first
time in this repo, and a real Skill invocation was then observed firing the full chain through to the
backend (`phase_start (1)` for session `e905cb67-eee1-4e4b-b889-baa96ab4996a`). This phase block is the
first in this run that can honestly record `emitted` rather than `confirmed-disabled`.

Interrupted-run recovery was exercised for real, not simulated. The session ended between
`refresh-delete-boot-files.sh` and the `setup.sh` re-invocation, leaving `CLAUDE.md` deleted and
`attemptStatus: "pending"` on disk. On resume, `planifest-refresh-setup` Step 2's recovery path identified
the state and replayed the recorded `attemptedCommand` without re-running detection. It worked as designed.

Three test repairs were needed, all recorded in commit `6d4baf3`. Two were stale expectations superseded by
this feature's own deliberate changes rather than accidental breakage, and one was a genuine test-isolation
defect. In every case the assertion was corrected to match intended behaviour rather than bypassed.

Verification detail for REQ-004 and REQ-005 is in `plan/current/verification-report.md`.
