---
title: "Tech debt: 0000028-telemetry-hardening-and-enforcement-fixes"
summary: "Duplication and placement items deliberately left alone during this feature, each with the reason it was not folded in and what a future requirement would need to do it safely."
status: "open"
version: "0.1.0"
---
# Tech debt - 0000028

**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes

Items recorded here were found during req-002's shared module extraction and deliberately not acted on. Each is a live duplication or placement concern, not a hypothetical.

## TD-001: `getSessionId()` has 4 copies across 3 behaviour profiles

**Where:** `planifest-framework/hooks/telemetry/context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `resolve-phase.mjs`.

**Why it was left alone:** unlike every other helper req-002 extracted, these 4 copies are not equivalent. Three distinct profiles:

| Copy | Priority chain | Session file |
|------|----------------|--------------|
| `context-pressure.mjs` | transcript path, then `input.session_id`, then `pid-${process.ppid}` | never touched |
| `emit-phase-start.mjs` | env var, `input.session_id`, transcript path, then session file | **creates** `{cwd}/.claude/.planifest-session` when absent |
| `emit-phase-end.mjs`, `resolve-phase.mjs` | same 4-priority order as above | read-only, falls back to `pid-${process.pid}` |

Two independent axes vary (create-vs-read-only, and 2-priority vs 4-priority), so a single parameterized function needs two flags and every caller still passes a different combination. That buys no safety over 4 local copies while adding a shared surface where a wrong default silently changes which session id a hook reports, or starts creating a session file from a hook that never did. req-002 named this exclusion explicitly.

**What a future requirement needs:** the before/after table req-002's acceptance criteria describe, over a fixed synthetic input set (present `session_id`; present `transcript_path` only; neither present with and without an existing session file) across all 4 callers, proving each profile is preserved. The snapshot harness built for req-002 already covers most of these fixtures and could be extended rather than rebuilt.

**Mitigation in place:** each copy now carries a comment naming its profile and pointing here, so the next person to touch one knows the other three are not the same function.

## TD-002: `readStdin()` still has 8 copies outside the two hook trees

**Where:** `planifest-framework/hooks/adapters/` (`cline.mjs`, `codex.mjs`, `copilot.mjs`, `cursor.mjs`, `windsurf.mjs`) and `planifest-framework/hooks/context-mode/` (`block-bash.mjs`, `block-grep.mjs`, `block-webfetch.mjs`).

**Why it was left alone:** req-002 and 0000028-ADR-002 scope the extraction to `hooks/enforcement/` and `hooks/telemetry/`, and reason about placement purely in terms of those two trees' install conditions. The adapters install to a different destination (`{tool}/hooks/adapters/`, with the adapter itself deriving `HOOKS_DIR` from its own `dirname`), and `hooks/context-mode/` installs only under `--context-mode-mcp`. Folding either in needs its own placement analysis of which tree is the superset under those conditions. Doing it unanalysed is the exact failure ADR-002 exists to prevent.

**Cost of leaving it:** the NFR-001 fix in the shared `readStdin` (settling on a stdin stream error instead of aborting the process non-zero) does **not** reach these 8 files. They retain the pre-extraction shape.

**What a future requirement needs:** trace the adapter and context-mode install paths in `setup.sh` and `setup.ps1` the way ADR-002 traced the other three, decide the superset tree, then rewire one caller at a time under ADR-004's sequencing.

## TD-003: `resolve-phase.mjs`'s `endDedupFlag()` sits beside a shared `getFlagPath()`

**Where:** `planifest-framework/hooks/telemetry/resolve-phase.mjs`.

**Why it was left alone:** req-002 rules it explicitly out of scope. It builds a different filename (`phase-end-emitted-{session}-{phase}`) for a different purpose (the resolver's own re-exec dedup) from `get-flag-path.mjs`'s `phase-start-{session}-{phase}`. They are neighbours, not duplicates.

**Cost of leaving it:** low. The risk is a future reader merging them on the assumption they are the same helper, which would break the phase_end dedup. The comment in `get-flag-path.mjs` records why they are separate.
