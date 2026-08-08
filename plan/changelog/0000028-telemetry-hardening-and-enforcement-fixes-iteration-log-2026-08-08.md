---
title: "Iteration Log - 0000028-telemetry-hardening-and-enforcement-fixes"
summary: "Execution log for the agent session."
status: "active"
version: "0.1.0"
---
# Iteration Log - 0000028-telemetry-hardening-and-enforcement-fixes

> **Audience:** Build-assessment-agent (P8) and post-run technical review. This is NOT the PR changelog: the PR changelog (written by ship-agent Step 1) is the human-readable audit trail for PR reviewers.

**Skill:** [docs-agent](../../planifest-framework/skills/planifest-docs-agent/SKILL.md)
**Date:** 2026-08-08
**Wave:** single wave (not waved)
**Version:** 0.27.0 to 0.28.0

## Iteration Steps Completed

| Phase | Status | Gate Result | Notes |
|-------|--------|-------------|-------|
| 0 - Assess & Coach | pass | Design confirmed: yes, 08 Aug 2026 @ 01:28 PM BST | 10 recorded exchanges. Scope collapsed twice on evidence: `0000042` dropped to a closure once `block-bash.mjs` was found already fixed in `0000026`, and the phase-hook wiring requirement became an install refresh once `setup.sh:626` was found already doing the wiring. Four Scope Lock drafts dispatched in parallel, each accepted separately. Run mode: continuous |
| 1 - Specification | pass | All artifacts produced: yes | 6 requirements drafted by 6 parallel subagents in one batch. Three P0 claims corrected and two fresh defects found while specifying |
| 2 - ADRs | pass | 4 ADRs generated | One parallel batch. ADR-002 corrected a P1 premise: neither consumer imported a phase-enum module yet, so the placement decision was forward-looking rather than a fix |
| 3 - Code Generation | pass | Implementation complete: yes | 3 deviations, all recorded in ADR-002 and `tech-debt.md`. 41 commits. REQ-002's extraction ran sequentially under ADR-004; REQ-006 ran in parallel beside it |
| 4 - Validation | pass | CI clean: yes | 56 feature suites and 22 regression tests green. 3 test repairs, none by weakening an assertion |
| 5 - Security | pass | Critical findings: 0 critical, 1 High (fixed in phase), 4 Low, 3 Informational | Overall rating High, driven entirely by SEC-001. Fixed within P5 and re-verified live in both directions |
| 6 - Docs & Ship | pass | All docs synced: yes | Gate B auto-accepted under continuous run. 4 living docs updated, 8 backlog entries filed, 9 closed |

## Requirement Changes During Run

| Change | Phase Active | Classification | Action Taken |
|--------|-------------|----------------|-------------|
| REQ-001's hook count corrected from five to three. The P0 check grepped for the absence of `RETRY_DELAYS_MS`, which proves no retry exists but says nothing about whether a `fetch` does. Direct inspection found `fetch` in exactly three hooks, so backlog `0000063`'s original count stood and P0's correction of it was the error | P1 | cosmetic (narrows an estimate, no criterion changed) | Corrected in `design.md` Corrections, `feature-brief.md` and `req-001`. `scope.md` was not updated and still reads five; see REC-010 |
| Em dash cleanup volume corrected from roughly 870 files to 99 files and 772 occurrences. The P0 figure came from an unscoped repo-wide count; scoped to live artifacts, excluding `plan/_archive/` and `plan/changelog/`, the real figure is far smaller. The unscoped whole-repo count is 1,010 | P1 | cosmetic | Corrected in REQ-006. The final cleanup touched roughly 100 files, and P5 analysed 104 changed markdown files |
| REQ-002 duplication extent widened from the two helpers backlog `0000054` and `0000057` describe to six, plus a latent NFR-001 violation in `readStdin()` | P1 | additive | Scope widened in `design.md` and `req-002`. `getSessionId()` inspected and explicitly excluded once three behaviour profiles were found across its four copies |
| `read-stdin.mjs` moved from `hooks/telemetry/` to `hooks/enforcement/` against ADR-002 as first written | P3 | contradictory (reverses a stated ADR decision) | ADR-002 amended in place with the reasoning and the correction marked as made during implementation. The original placement would have left `check-telemetry-receipts.mjs` and `check-telemetry-failures.mjs`, both installed unconditionally, importing an absent module on every install without `--structured-telemetry-mcp`, which is the majority case. Verified by building a telemetry-free install and running the hook against it |
| `readStdin()` copy count corrected from 7 to 12, then to 13 | P3 | cosmetic | ADR-002 amended. The 13th was added by REQ-006's own `em-dash-guard.mjs` while the feature was in flight, and was folded into the shared module in commit `2bd14f5` |
| A third independent encoding of the phase enum found: `emit-event-receipt.mjs`'s `KNOWN_PHASES`, the closed-set guard against path traversal added at 0000027 P5 | P3 | additive | Derived from the shared enum alongside the two lookup tables, so the security guard cannot drift out of step with them. P5 verified the guard byte-equivalent in effect and unweakened |
| SEC-001: every `hooks/enforcement/` hook wired as a bare `.mjs` path, exiting 126 and never running | P5 | additive (a pre-existing defect, not a change to this feature's requirements) | Fixed in phase by prefixing every enforcement command string with `node`, matching `setup.ps1`, which had always been correct. Re-verified live in both directions. Static wiring assertions plus a bare-path regression guard added |

## Self-Correct Log

**P3, three test repairs (commit `6d4baf3`).** Two were stale expectations superseded by this feature's own deliberate changes rather than accidental breakage, and one was a genuine test-isolation defect. In every case the assertion was corrected to match intended behaviour rather than bypassed or weakened.

**P3, ADR-002 placement reversal.** The one substantive self-correction of the run. `read-stdin.mjs` was placed in `hooks/telemetry/` on the reasoning that no caller is ever active while `telemetry/` is absent. That reasoning was wrong for exactly the reason ADR-002's own phase-enum decision identifies two bullets later. Caught before any caller was rewired, because ADR-004's sequencing requires the module to exist and be verified before any import points at it. Verified by construction rather than by argument: a `setup.sh claude-code` install with no telemetry flag produces `.claude/hooks/enforcement/` with no sibling `telemetry/` directory, and `check-telemetry-receipts.mjs` run against it resolves both shared imports and completes its check.

**P4 to P5, interrupted-run recovery, exercised for real rather than simulated.** The session ended between `refresh-delete-boot-files.sh` and the `setup.sh` re-invocation, leaving `CLAUDE.md` deleted and `attemptStatus: "pending"` on disk. On resume, `planifest-refresh-setup` Step 2's recovery path identified the state from those two facts and replayed the recorded `attemptedCommand` without repeating detection. An unplanned but genuine live test of a path that had never been exercised, and it passed.

**P5, SEC-001.** Not a self-correction of this feature's own work but of the repository's, found by execution rather than inference: the same payload against the same file returned 126 through the wired form and 2 through `node`. Fixed in phase.

## Quirks

Recorded in `planifest-framework/component.yml` and `src/setup-hook-integration/docs/quirks.md`.

- **Cross-directory imports have a required direction.** `hooks/telemetry/` may import from `hooks/enforcement/`, never the reverse. `enforcement/` installs unconditionally, `telemetry/` only under `--structured-telemetry-mcp`, so any helper with an enforcement caller must live in the always-present tree. An import resolving the wrong way fails at ESM module-load time, before the hook's own `try/catch`, so it exits non-zero rather than degrading gracefully, which is the opposite of the exit-zero invariant.
- **Hooks install as copies, not symlinks.** A shared module exists at runtime only because a `setup.sh` glob copies it. The tier 1 telemetry glob was `emit-phase-*.mjs`, which would have installed the callers and dropped every module they import, for Cursor, Windsurf and Cline. Widened to `*.mjs` in both `setup.sh` and `setup.ps1`.
- **`setup.sh` copies but never prunes.** A module renamed or deleted upstream leaves a stale copy behind. No orphans exist today, but a `*.mjs` glob makes this worth watching where a two-file implicit allowlist did not.
- **The em dash guard has a deliberately narrow reach.** It matches only `Write` and `Edit`, only under five relative path prefixes. A write made through Bash, or via an absolute path outside `cwd`, is not inspected. Its bypass sentinel matches anywhere in the payload, so any document quoting the sentinel exempts itself. This is a style rule about one character, not an authorisation control, and ADR-003 models it as such.
- **Retry worst case is 9.6s, not 600ms.** 600ms is the sleep budget; each of the three attempts carries its own 3s abort. Against a refusing localhost listener the real cost is about 600ms, which is where the original figure came from. Both are now recorded in `risk-register.md` R-007.
- **`getSessionId()` still has four copies and they are not the same function.** Each now carries a comment naming its behaviour profile and pointing at the other three.

## Recommended Improvements

Full detail in `plan/current/recommendations.md`: 13 recommendations, 2 deferred items, 6 tech debt rows, with all 8 of the latter two filed as `plan/backlog/` entries `0000065` through `0000072`.

Flagged for human attention before the PR, in priority order:

1. **REC-009, the build log is missing its P4 and P5 blocks.** Both phases ran and produced substantial artifacts, including a High security finding fixed in phase. Hard Limit 8 requires a phase block at every phase. P6's block has been added by this phase; P4 and P5 should be reconstructed by the orchestrator before P7 archives the file, since the build log is P8's only input and the gap becomes permanent once archived.
2. **REC-001 and backlog `0000071`, no test executes an enforcement hook through the command string the installer writes.** This is the exact blind spot that hid SEC-001 across 56 test suites. The P5 fix added a shape assertion and a bare-path pattern guard, which catches the next regression only if it looks like the last one.
3. **REC-010, `scope.md` still reads "all five telemetry hooks" for REQ-001.** Corrected everywhere else at P1. Flagged rather than fixed here, since `scope.md` is a P1 artifact and the correction belongs with whoever owns the reversal record.
4. **REC-002 and backlog `0000070`, `AbortError` sits inside the retry predicate by accident rather than by decision.** Either exclusion or an explicit event id would settle it. Telemetry is the governance audit trail, so duplicates there are a records-integrity matter.
5. **REC-011, backlog `0000053` is answered but narrower work remains.** The backend accepts `loop_iteration` and the three `phase_reversal_*` events at ingestion, which closes Root Cause B of the `0000017` RCA. That a real loop emits well-formed events at the right points is still unverified, because no toggle was enabled and emitting a synthetic loop would have inserted a fabricated iteration into the store that P8 later reads as real.
6. **REC-004, third sighting of the `docs/component-registry.md` `src/` path claim.** Flagged in `0000025`, `0000027` and now here. Backlog `0000061` is the governed home and was deliberately left at this feature's P0, so it stays unfixed; the age is recorded so the next pickup sees it.
