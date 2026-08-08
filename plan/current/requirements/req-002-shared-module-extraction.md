---
title: "Requirement: req-002 - Shared module extraction"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-002 - Shared module extraction

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source:** US-002
**Priority:** must-have

## User Story

As a framework maintainer, I want the duplicated emit-and-record logic extracted into one shared module, so that a fix to it is applied once instead of five times.

## Functional Requirements

Investigation of `planifest-framework/hooks/telemetry/*.mjs` and `planifest-framework/hooks/enforcement/check-telemetry-*.mjs` found a larger duplication surface than either source backlog entry states alone. Backlog `0000054` and `0000057` each name one duplicated item; the true surface is five distinct duplicated or near-duplicated pieces.

- **`readStdin()`** appears in all 7 hooks: `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `emit-event-receipt.mjs`, `resolve-phase.mjs`, `check-telemetry-receipts.mjs`, `check-telemetry-failures.mjs`. Two textual variants exist (BOM stripped via `/^﻿/` in the first three, via a literal BOM character `/^﻿/` in the other four) but there is also a real behavioral difference: only `context-pressure.mjs`'s copy wires `process.stdin.on("error", reject)`; the other 6 do not, so a stdin stream error on those 6 leaves the returned promise unresolved forever rather than rejecting. Extraction must not silently collapse this difference either way — see acceptance criteria.
- **`readProductId(cwd)`** appears in `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs` (3 copies, confirmed byte-identical by diff). Not present in `emit-event-receipt.mjs` or `resolve-phase.mjs`, which never call it. Extract as-is into a shared module; no behavioral ambiguity here.
- **`recordTelemetryFailure(hookName, err, context)`** appears in `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `emit-event-receipt.mjs` (4 copies). Diff confirms the only differences across all 4 are comment text (an "NFR-001" vs "ADR-005" tag reference in one line, and `emit-event-receipt.mjs`'s copy omits 3 comment lines) — the executable logic is 100% identical. `resolve-phase.mjs` has no copy of this function; on failure it fails open silently with no marker, which is correct per its own header and out of scope to change here.
- **The emit-and-record fetch block** (`AbortController`, 3s abort timer, POST to `${BACKEND_URL}/emit`, `!res.ok` → synthetic `http_<status>` error) appears in `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs` (3 copies). This is the block req-001 (bounded retry) also touches. If req-001 lands first, this extraction must lift its retry loop into the shared module rather than the pre-retry version; if req-002 lands first, the retry loop from req-001 must be added directly to the shared module, never re-duplicated per hook a third time. Only the post-event mechanics are shared — each hook's event-object construction (`context_pressure` vs `phase_start` vs `phase_end` field values) stays local, since those payloads genuinely differ.
- **`getSessionId()`** appears in `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `resolve-phase.mjs` — 4 copies, and unlike the functions above these are NOT identical: `context-pressure.mjs` uses a 2-priority check (transcript path, then `input.session_id`, then a pid fallback) and never creates a session file; `emit-phase-start.mjs` uses a 4-priority check and creates `{cwd}/.claude/.planifest-session` if absent; `emit-phase-end.mjs` and `resolve-phase.mjs` use the same 4-priority order as `emit-phase-start.mjs` but are read-only (no file creation). A naive merge would either start creating a session file from hooks that currently never do, or stop creating one from `emit-phase-start.mjs`, both of which are behavior changes. Extraction must preserve all 3 profiles exactly, parameterized (e.g. a `createIfAbsent` flag), not unified by assumption.
- **`getFlagPath()`** appears in `emit-phase-start.mjs` and `emit-phase-end.mjs` (2 copies, identical string construction: `join(tmpdir(), "planifest-telemetry", \`phase-start-${sessionId}-${PHASE}\`)`). `resolve-phase.mjs`'s `endDedupFlag()` is related but not the same thing (different filename pattern, different purpose — dedup for the resolver's own re-exec, not the underlying hook's flag) and is out of scope to merge into this helper.
- **Phase-enum maps** (backlog `0000057`, confirmed): `check-telemetry-receipts.mjs`'s `PHASE_NUMBER_TO_ENUM` (9 numeric keys, P1-P9, → 7 enum values) and `resolve-phase.mjs`'s `PHASE_SKILLS` (7 skill-name keys → the same 7 enum values) encode the same canonical phase enum (`spec`, `adr`, `codegen`, `validate`, `security`, `docs`, `ship`) from two different key spaces. Extract one canonical source (for example an ordered phase-enum list or a base map keyed by the enum itself) and derive both the number-keyed and skill-name-keyed lookups from it, so a phase cannot be added to one map without the other.

### Sequencing (design.md risk, mandatory)

This feature edits the hooks that run its own build. Because every hook must exit 0 on every path, a hook that imports a shared module which does not yet exist does not fail visibly — the ESM import fails at module-load time, before the hook's own top-level try/catch ever runs, and the hook's observable behavior degrades to a silent no-op (or worse, a hard process crash, for a hook the caller expects to always exit 0). To prevent this:

- Every shared module must be created, fully populated, and committed before any caller file's import statement is rewired to use it. No commit may contain a caller importing a module that does not exist in that same commit.
- After rewiring a caller, verify live — invoke the hook directly with representative stdin against the actual installed copy under `.claude/hooks/`, not just against the source tree under `planifest-framework/hooks/`. Do not infer correctness from a source diff alone.

### Installation accounting (two-copy problem)

`planifest-framework/hooks/` is the git-tracked source of truth; `.claude/hooks/` is an untracked, gitignored copy written by `setup.sh` (`.gitignore` line 2 ignores `.claude/` wholesale). Investigation of `setup.sh` found 3 relevant install code paths with different copy behavior, all of which a shared module must survive:

- `install_enforcement_hooks()` (`setup.sh:557`) and `install_telemetry_hooks()` (`setup.sh:778`) both copy every `*.mjs` file (full glob) from `hooks/enforcement/` and `hooks/telemetry/` respectively into their `.claude/hooks/` counterparts. A shared module dropped into either source directory is picked up automatically by these two loops — no `setup.sh` change needed for this path.
- `install_tier1_hooks()` (`setup.sh:447`, used for Cursor/Windsurf/Cline) copies telemetry scripts with a narrower glob, `emit-phase-*.mjs`, not `*.mjs`. A shared module placed in `hooks/telemetry/` would NOT be copied by this path even though `emit-phase-start.mjs` and `emit-phase-end.mjs` (which ARE copied under Tier 1) would import it — this must be fixed as part of this requirement, either by widening the Tier 1 glob or copying the shared module explicitly by name.
- Tier 1 installs skip `hooks/enforcement/` entirely (`setup.sh:1180`, `! [[ "${PLANIFEST_TIER:-}" =~ ^1 ]]`), so no shared module needed only by enforcement hooks is a concern for Tier 1.
- For non-Tier1 installs: `hooks/enforcement/` installs unconditionally; `hooks/telemetry/` installs only when `--structured-telemetry-mcp` is set. The phase-enum module is needed by both `check-telemetry-receipts.mjs` (enforcement, always installed) and `resolve-phase.mjs` (telemetry, conditionally installed). Because `resolve-phase.mjs` itself is only ever on disk when telemetry is enabled, and `hooks/enforcement/` is always installed whenever anything is, the phase-enum module must live in `hooks/enforcement/` (the always-present superset) and be imported by `resolve-phase.mjs` across the sibling directory boundary — not the reverse. Placing it in `hooks/telemetry/` instead would leave `check-telemetry-receipts.mjs` importing a module that was never installed whenever telemetry is off, which is a hard module-load crash, not a silent no-op.

## Acceptance Criteria

- [ ] Every shared module exists, fully populated, in a commit that precedes any commit rewiring a caller to import it.
- [ ] `readStdin`, `readProductId`, `recordTelemetryFailure`, and the post-event (`fetch` + abort + retry) helper each exist in exactly one place in `planifest-framework/hooks/`, imported by relative path from every current caller listed above.
- [ ] `readStdin`'s stdin-error-rejection discrepancy (present only in `context-pressure.mjs` today) is either preserved exactly per caller via a parameter, or changed deliberately with the change called out in this requirement's Dependencies and confirmed with the human on the loop — never silently collapsed either direction.
- [ ] `getSessionId`'s 3 distinct behavior profiles (create-vs-read-only, 2-priority vs 4-priority) are preserved exactly per caller after consolidation. Verified by a before/after table over a fixed synthetic input set (present `session_id`, present `transcript_path` only, neither present with and without an existing session file) covering all 4 current callers.
- [ ] The phase enum is defined in exactly one place; `PHASE_NUMBER_TO_ENUM` and `PHASE_SKILLS` are both derived from it, or both replaced by lookups against it, so a phase cannot be added to one without the other.
- [ ] `setup.sh`'s Tier 1 telemetry install glob is updated so any shared telemetry module is copied to a Tier 1 target alongside `emit-phase-start.mjs` / `emit-phase-end.mjs`.
- [ ] The phase-enum module's placement is verified against all 4 install-flag combinations (telemetry on/off × Tier 1/non-Tier 1) by tracing `setup.sh`'s install functions, not assumed.
- [ ] This repo's own `.claude/hooks/` install is refreshed (`setup.sh` re-run) after extraction, and every rewired hook is invoked live against the refreshed install with representative stdin, confirmed to exit 0 and produce the same observable output (event posted, marker written, or stdout JSON) as before the refactor.
- [ ] No hook's behavior changes for any input that exercised it before this requirement, except a change explicitly called out above as deliberate.
- [ ] No `package.json` is introduced anywhere in this repo; every shared module is a plain `.mjs` file imported by relative path.

## Dependencies

- req-001 (bounded retry on network-level emission failures) is the natural predecessor for the fetch/AbortController extraction: whichever requirement lands second must incorporate the other's work into the shared module rather than re-duplicating it.
- Backlog `0000054` (`readProductId`) and `0000057` (phase-enum maps) are the two duplication points named in advance; this requirement's actual scope is larger, per the Functional Requirements section above — `readStdin` (7 files), `recordTelemetryFailure` (4 files), the fetch/AbortController block (3 files), and `getSessionId`'s non-identical 4-way variance are all in scope too.
- `planifest-framework/setup.sh`'s `install_enforcement_hooks()`, `install_telemetry_hooks()`, and `install_tier1_hooks()` functions gate whether a shared module is physically present at each caller's runtime location. Placement decisions in this requirement are constrained by their current glob behavior, documented above.
