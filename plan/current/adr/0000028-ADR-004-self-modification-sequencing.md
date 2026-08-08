---
title: "ADR 004: Self-modification sequencing for hook extraction and reinstall"
summary: "Rewire one caller at a time, re-run setup.sh after each, and verify each hook's live side effect immediately, since exit 0 cannot distinguish a working hook from a silently broken one."
status: "proposed"
version: "0.1.0"
---
# ADR-004 - Self-modification sequencing for hook extraction and reinstall

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

This feature rewrites `planifest-framework/hooks/telemetry/*.mjs` and re-runs `setup.sh`, which rewrites `.claude/settings.json` and the installed hook copies under `.claude/hooks/`. Those installed hooks are the ones executing during the very session doing the editing.

Planifest requires every hook to exit 0 on every path (NFR-001), so the host session never blocks unexpectedly. That same property removes the normal failure signal: a hook broken mid-edit does not crash loudly, it degrades to a silent no-op. An ESM import of a shared module that does not yet exist fails at module-load time, before the hook's own top-level try/catch runs, so exit code alone tells an operator nothing about whether the hook actually did its job.

`.gitignore` line 2 ignores `.claude/` wholesale. Recovery is asymmetric: tracked source under `planifest-framework/hooks/` recovers via `git checkout`; the live install has no such history and recovers only by re-running `setup.sh`. There is no "last known good" `.claude/` state to roll back to.

req-002 already establishes two hard rules this ADR builds on: every shared module must be created, fully populated, and committed before any caller's import is rewired, and no commit may contain a caller importing a module absent from that same commit. This ADR covers the operational sequencing around those rules: when to re-run `setup.sh`, when to verify, and how to detect a no-op given exit 0 proves nothing.

## Decision

Rewire one caller at a time. For each caller (each `.mjs` file whose imports change):

1. Edit the source file in `planifest-framework/hooks/` to import the already-committed shared module. Commit.
2. Re-run `setup.sh` immediately, for this edit alone. Do not batch multiple callers' edits before re-running setup.
3. Invoke the rewired hook directly against the refreshed `.claude/hooks/` copy, with representative stdin, and check its actual side effect, not its exit code: for an emit hook, confirm the POST reached the backend (or that `recordTelemetryFailure()` wrote the expected marker on a deliberately failing case); for `resolve-phase.mjs`, confirm the downstream emit hook it spawns produced its own confirmed side effect, since `resolve-phase.mjs` fails open by design and its own exit code is uninformative either way.
4. Only after that positive-evidence check passes does the next caller get rewired. An unverified rewire blocks all further edits.

Re-running `setup.sh` once "at the end" after several callers are rewired blind is rejected: it collapses the failure mode this discipline exists to prevent, because a live install could jump from good straight to multiply-broken with no way to isolate which edit caused it.

Detecting a silent no-op: since exit 0 is uninformative, every verification step must assert a fact that could only be true if the import resolved and the code executed end to end (event received, marker file written, downstream process spawned), never merely "the process returned."

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Scratch copy, swap at the end | Isolates all edits from the live session until one final swap | The swap itself is a single `setup.sh` re-run touching the still-running session's hooks, so the same silent-no-op risk just moves to one big-bang moment instead of being caught incrementally; two divergent trees can drift against req-002's ordered-commit model | Defers the risk instead of reducing it, and forfeits the incremental live verification design.md's mitigation calls for |
| Disable hooks for the duration of the build | Removes the exit-0-masks-everything problem outright, any breakage becomes visible immediately | Hooks include enforcement (`gate-write`, `ratchet-check`, `commit-msg`), not only telemetry; disabling them means the framework's own quality guarantees go unenforced for the whole build, and disabling requires editing `.claude/settings.json`, the exact file this feature must prove it can rewrite correctly | Trades a telemetry risk for a larger governance risk, and never actually exercises the thing being built |
| Accept the risk, rely on P4 validation to catch it | Lowest effort, matches ordinary feature validation | P4 runs after every caller is already rewired; if hook N breaks silently at edit 2 of 7, edits 3-7 proceed blind with degraded telemetry and possibly degraded enforcement, and there is no way to bisect which edit caused it after the fact | Contradicts design.md's own mitigation ("verify live rather than assuming") and risk-register R-001's stated reasoning: a broken hook here would not be caught by the human noticing a block |
| Separate clone or worktree | Full isolation, live session hooks untouched until a deliberate merge | This repo's own CLAUDE.md instructions forbid git worktrees outright; a separate clone carries the same drift and big-bang-swap problem as the scratch-copy alternative, plus it duplicates gitignored `.claude/` local state (setup flags, install) that would need independent reconstruction | Forbidden by explicit repo instruction, and does not solve the underlying problem even where allowed |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | Every req-002 caller rewire follows this one-at-a-time sequence: edit, commit, re-run `setup.sh`, live-verify, only then proceed. req-004's install refresh is one instance of the same "re-run setup.sh, verify against `.claude/settings.json` directly" discipline, not a separate procedure. |

## Consequences

**Positive:**
- Each edit's blast radius is one caller, verified before the next begins; corruption is caught within one step, not accumulated across the whole build.
- The session's own hooks stay live and enforcing throughout, so the fix validates itself against the real environment req-004 depends on.
- Matches req-002's acceptance criteria and design.md's stated mitigation directly: shared modules before rewiring, verify live rather than assuming.

**Negative:**
- Slower: a `setup.sh` re-run plus a live invocation per caller (`readStdin` alone touches 7 files) instead of one batch edit and one setup run.
- More moving parts to track: repeated `setup.sh` re-runs add their own small surface for transient issues (permissions, partial copy) across the build.

**Risks:**
- A hook can pass its live check on representative stdin yet still regress on an input path the check does not exercise. Mitigation: req-002's acceptance criteria already require a before/after table over a fixed synthetic input set for the divergent `getSessionId` profiles, not a single ad hoc check.
- Under time pressure an operator may skip a verification step ("check them all at the end"), reintroducing the exact batching failure mode this ADR exists to prevent. Mitigation: treat every unverified rewire as blocking; the next caller does not get edited until the current one's live check passes.

**Operator procedure when a hook is found silently no-opping mid-run:** fix forward in source immediately, re-run `setup.sh` for that hook, re-verify live before touching the next caller. Do not attempt to roll back `.claude/` via git; it is gitignored and there is no prior state to check out. This is the cross-session Scope Lock answer already confirmed by the human on the loop: broken hooks are fixed forward and verified live, never assumed working.

## Related ADRs

- ADR-001 (network-level retry semantics) - related-to. Its shared fetch/retry block is one of the modules this sequencing discipline governs the extraction of.

## Supersedes

- None.

## Superseded By

- None.
