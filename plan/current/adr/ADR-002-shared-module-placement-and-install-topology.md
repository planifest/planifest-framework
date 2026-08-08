---
title: "ADR 002: Shared module placement and install topology"
summary: "Extracted shared hook modules live inside the existing hooks/enforcement/ and hooks/telemetry/ trees, one directory-scoped module per duplication cluster, with the phase-enum module placed in enforcement/ (always installed) rather than telemetry/ (conditionally installed), and the Tier 1 telemetry glob widened to stop silently dropping new shared modules."
status: "proposed"
version: "0.1.0"
---
# ADR-002 - Shared module placement and install topology

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

req-002 extracts six duplicated helpers out of `planifest-framework/hooks/telemetry/*.mjs` and `hooks/enforcement/check-telemetry-*.mjs` into shared modules. `hooks/` is git-tracked source; `.claude/hooks/` is the untracked, gitignored install copy (`.gitignore` line 2 ignores `.claude/` wholesale). Hooks are installed as copies, not symlinks, so a shared module only exists at runtime if some `setup.sh` code path actually copies it there. Three install paths copy differently:

- `install_enforcement_hooks()` (`setup.sh:527`, glob at `:557`) copies every `*.mjs` from `hooks/enforcement/` unconditionally for non-Tier-1 installs (`setup.sh:1180-1181`, gated only on `! PLANIFEST_TIER =~ ^1`, not on `--structured-telemetry-mcp`; the code comment at `:537` states neither `check-telemetry-*.mjs` hook belongs behind that flag).
- `install_telemetry_hooks()` (`setup.sh:756`, glob at `:778`) copies every `*.mjs` from `hooks/telemetry/`, but only runs when `--structured-telemetry-mcp` is passed (`setup.sh:1220`, `[ "$STRUCTURED_TELEMETRY_MCP" = true ]`).
- `install_tier1_hooks()` (`setup.sh:403`) is used for Cursor, Windsurf, Cline. It copies `hooks/enforcement/*.mjs` with a full glob (`:433`) and copies telemetry with the narrow glob `emit-phase-*.mjs` (`:447`). `install_enforcement_hooks()` itself is skipped for Tier 1 (`setup.sh:1180`, `! PLANIFEST_TIER =~ ^1`) since Tier 1 has its own enforcement copy at `:433` instead. The two paths are mutually exclusive per install, not additive.

Two placement-sensitive consequences follow directly:

1. Any new shared module dropped into `hooks/enforcement/` or `hooks/telemetry/` is picked up automatically by `install_enforcement_hooks()` and `install_telemetry_hooks()` (full glob, no `setup.sh` edit needed). A module dropped into `hooks/telemetry/` is **not** picked up by `install_tier1_hooks()`, because its telemetry glob is narrower than its own callers (`emit-phase-start.mjs`, `emit-phase-end.mjs`) require. This is a live bug independent of this feature and must be fixed as part of it.
2. `check-telemetry-receipts.mjs` lives in `hooks/enforcement/`, installed whenever anything is installed (non-Tier-1: unconditional; Tier 1: unconditional via its own `:433` copy). `resolve-phase.mjs` lives in `hooks/telemetry/`, installed only when `--structured-telemetry-mcp` is passed. Verified directly against `setup.sh`, not assumed: `hooks/enforcement/` is the always-present superset, `hooks/telemetry/` is the conditional subset.

Because hooks are plain ESM files, an `import` of a module that is not on disk fails at module-load time, before the hook's own top-level `try/catch` runs. A hook that is supposed to always exit 0 instead throws unhandled and exits non-zero, the opposite of the framework's own "hooks never block the session" invariant. Where the caller happens to be wrapped by something tolerant of a bad exit, this can also present as a silent no-op instead of a visible crash; either way the failure mode is caused by the same root issue: the module was never installed at the caller's location.

## Decision

Extract shared modules in place, inside the existing `hooks/enforcement/` and `hooks/telemetry/` trees, not into a new top-level `shared/` directory. Each duplication cluster from req-002 becomes one small `.mjs` module, imported by relative path from every current caller:

- `hooks/enforcement/read-stdin.mjs` for `readStdin()`. Used by both directories, placed in `enforcement/` and imported cross-directory by the `telemetry/` callers.

  **Corrected during implementation (req-002).** This ADR originally placed `read-stdin.mjs` in `hooks/telemetry/`, reasoning that "`readStdin` has no caller that is ever active while `telemetry/` is absent." That reasoning was wrong, and it is wrong for exactly the reason this ADR's own phase-enum decision identifies two bullets down. `readStdin`'s callers include `check-telemetry-receipts.mjs` and `check-telemetry-failures.mjs`, which live in `hooks/enforcement/` and are installed unconditionally (`setup.sh`'s own code comment at `install_enforcement_hooks()` states neither belongs behind `--structured-telemetry-mcp`). With telemetry off, `hooks/telemetry/` does not exist at all, so both hooks would import an absent module and fail at ESM module-load time on the majority install. Placement follows this ADR's standing rule instead: `enforcement/` is the always-present superset, `telemetry/` is the gated subset, so a helper with any enforcement caller lives in `enforcement/`.

  Verified rather than assumed: a `setup.sh claude-code` install with no telemetry flag produces `.claude/hooks/enforcement/` with no sibling `telemetry/` directory, and `check-telemetry-receipts.mjs` invoked against it resolves both shared imports and completes its check.

  The count is also larger than this ADR first recorded: `readStdin` had 12 identical-by-behaviour copies across `hooks/enforcement/` (7) and `hooks/telemetry/` (5), not 7, plus a 13th added by req-006's `em-dash-guard.mjs` while this feature was in flight. All 13 now import the shared module.
- `hooks/telemetry/read-product-id.mjs` for `readProductId()`. All 3 callers are in `telemetry/`.
- `hooks/telemetry/record-telemetry-failure.mjs` for `recordTelemetryFailure()`. All 4 callers are in `telemetry/`.
- `hooks/telemetry/emit-event.mjs` for the fetch/AbortController/retry block. All 3 callers are in `telemetry/`.
- `hooks/telemetry/get-flag-path.mjs` for `getFlagPath()`. Both callers are in `telemetry/`.
- `hooks/enforcement/phase-enum.mjs` for the canonical phase enum, imported by `check-telemetry-receipts.mjs` (same directory), `resolve-phase.mjs` and `emit-event-receipt.mjs` (`hooks/telemetry/`, cross-directory import up to `../enforcement/phase-enum.mjs`).

  A third independent encoding of the same enum was found during implementation: `emit-event-receipt.mjs`'s `KNOWN_PHASES`, the closed set guarding path construction against traversal (CWE-22). It is now derived from the shared enum alongside `PHASE_NUMBER_TO_ENUM` and `PHASE_SKILLS`, so the security guard cannot fall out of step with the two lookup tables.

`getSessionId()` is excluded from consolidation per req-002 (three genuinely different behaviour profiles; unifying it is a behaviour change, not a refactor).

The phase-enum module is placed in `hooks/enforcement/`, not `hooks/telemetry/`, specifically because `check-telemetry-receipts.mjs` (enforcement, always installed) needs it and `resolve-phase.mjs` (telemetry, conditionally installed) does not gate its own presence on anything the phase-enum module depends on. Placing it in the always-present superset means the conditional consumer (`resolve-phase.mjs`) only ever exists on disk when telemetry is on, and telemetry being on never removes `hooks/enforcement/` from the install. The reverse placement would leave `check-telemetry-receipts.mjs` importing a module that is absent whenever telemetry is off, a hard crash on every non-telemetry install, which is the majority case (no `--structured-telemetry-mcp` flag).

`setup.sh:447`'s Tier 1 telemetry glob is widened from `emit-phase-*.mjs` to `*.mjs`, matching the pattern already used by `install_enforcement_hooks()` and `install_telemetry_hooks()`. `setup.ps1`'s `Install-Tier1Hooks` carries the identical narrow filter (`Get-ChildItem -Filter 'emit-phase-*.mjs'`) and is widened with it, since the two scripts are held at parity by test. This is corrected regardless of exactly which shared modules end up under `hooks/telemetry/`, since the narrow glob is a latent bug the moment any file other than `emit-phase-start.mjs` / `emit-phase-end.mjs` is added to that directory, extraction or not. Widening to `*.mjs` also means `context-pressure.mjs`, `emit-event-receipt.mjs`, and `resolve-phase.mjs` become installable under Tier 1 for free, though none is currently wired into the Tier 1 adapter's own registration; that wiring is out of scope here.

Sequencing constraint (already stated in req-002, restated here as the binding reason for the alternatives rejected below): every shared module must exist, fully populated, in a commit before any caller's import statement is rewired to use it. No commit may contain a caller importing a module absent from that same commit.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Single flat `hooks/shared/` directory for all six modules | One place to look; no cross-directory imports | A fourth top-level hooks directory needs its own install-glob entry in all three `setup.sh` functions, including a fresh Tier 1 decision, and Tier 1 has no existing precedent for a third hooks subdirectory. Also breaks the "always/conditional" distinction that makes the phase-enum placement decision legible: everything in `shared/` would need the always-present treatment or none of it would. | Adds a new install code path for no gain over placing each module in whichever existing tree already installs on the right condition. The always/conditional split enforcement/ vs telemetry/ already provides is exactly the distinction this feature needs; a flat directory erases it. |
| Per-tier duplication accepted as-is (status quo; backlog `0000054`'s stated convention) | Zero install-topology risk; no cross-directory imports; matches existing precedent elsewhere in this repo | Directly contradicts req-002's purpose (US-002: fix once, not five times) and leaves the phase-enum's two independently-maintained maps able to drift, which is the exact defect backlog `0000057` was filed against | req-002 exists because duplication already caused drift risk. Accepting the status quo here is declining the requirement, not an implementation choice. |
| Symlinks from `.claude/hooks/` to `planifest-framework/hooks/` instead of copies | A shared module is present everywhere its source is, with zero glob logic | `.claude/` (and each tool's install dir) is gitignored and reconstructed by `setup.sh` on every run. Introducing symlinks changes the install mechanism for every existing hook, not just the new shared modules, and this repo's own architecture already treats the copy model as an accepted constraint (0000028 design.md Risks: "`.claude/` being gitignored means the live hook install cannot be restored with `git checkout`, only by re-running setup"). | Out of proportion to req-002's scope. Changing copy-vs-symlink for all hooks is a separate decision with its own blast radius (Windows/Cursor/Windsurf symlink support, git worktree behaviour) that this requirement does not need to make to satisfy its acceptance criteria. |
| Bundle all hooks (or all telemetry hooks) into one file, eliminating cross-file imports entirely | No install-glob or placement problem at all: one file, one copy | Defeats the "no `package.json`, dependency-free Node ESM" constraint's spirit by forcing a build/concat step where none exists today. Makes each hook's diff noisy (unrelated hooks' code in the same file) and contradicts req-002's acceptance criteria, which name each helper as extracted "into a shared module" (singular helper modules), not a monolith. | No build step exists in this repo today and introducing one to solve a glob bug is disproportionate. The three install functions already glob-copy individual files correctly (`enforcement/`, `telemetry/` full globs); only Tier 1's telemetry glob needs a one-line fix. |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | Six new shared `.mjs` modules under `hooks/enforcement/` and `hooks/telemetry/`; all current callers rewired to import by relative path; `setup.sh:447` glob widened from `emit-phase-*.mjs` to `*.mjs`. |
| setup-hook-integration | Tier 1 (Cursor, Windsurf, Cline) installs gain the widened telemetry glob; no other install path changes shape, only file count. |

## Consequences

**Positive:**
- A fix to `readStdin`, `readProductId`, `recordTelemetryFailure`, the emit/retry block, `getFlagPath`, or the phase enum is now made once, not up to seven times.
- The phase enum can no longer drift between `PHASE_NUMBER_TO_ENUM` and `PHASE_SKILLS`, since both derive from one source.
- The Tier 1 glob fix is a general-purpose correction: any future file added to `hooks/telemetry/` is installed for Cursor, Windsurf, and Cline without a further `setup.sh` change.

**Negative:**
- `resolve-phase.mjs` now imports across a directory boundary (`../enforcement/phase-enum.mjs`), a cross-tree dependency that didn't exist before; the always/conditional install reasoning must be re-checked by hand if either directory's install condition ever changes.
- Six new files to track and keep in sync with their callers' relative import paths if either directory is ever renamed.

**Risks:**
- A missing shared module makes an importing hook throw at ESM module-load time, before the hook's own top-level try/catch runs. Because every hook is required to exit 0 on every path, this failure mode is worse than a normal bug: depending on how the caller invokes the hook, it presents either as a hard non-zero exit (violating the "never block the session" invariant directly) or, where the caller tolerates a bad exit, degrades to a silent no-op with no marker and no stderr line. This is why the sequencing rule (shared module committed before any caller import) and the Tier 1 glob fix are both treated as mandatory in this ADR's Decision, not optional cleanup. Mitigation: req-002's acceptance criteria require every rewired hook to be invoked live against the refreshed `.claude/hooks/` install, with representative stdin, confirmed to exit 0 with unchanged observable output, before the requirement is considered done.
- If a future shared module is added only to `hooks/enforcement/` or only to `hooks/telemetry/` without re-checking which install conditions apply, the same crash-on-missing-import failure can recur for a different module. Mitigation: this ADR's always/conditional reasoning (enforcement is the superset, telemetry is the gated subset) is the standing rule for placing any future shared module between these two directories, not a one-off judgement for the phase enum alone.

## Related ADRs

- 0000028-ADR-001 - depends-on (this ADR's emit-event.mjs module must incorporate ADR-001's retry loop rather than re-duplicating it, per req-002's stated sequencing with req-001).

## Supersedes

- None.

## Superseded By

- None.
