# Changelog — 0000019-self-description-and-session-hygiene-fixes — 31 Jul 2026

**Feature:** Self-Description and Session-Hygiene Fixes
**Pipeline run:** P0–P9 completed, continuous run authorized at design confirmation; no phases skipped
**Version:** 0.18.0 → 0.19.0
**PR:** [#44](https://github.com/planifest/planifest-framework/pull/44)

## What Was Built

An independent external framework review found the repository's own self-description had drifted from reality — wrong README counts on five of seven table rows, two structure-diagram paths that didn't resolve, a `component.json`/`component.yml` mismatch that falsely rejected valid changes in the shipped git hooks, an overclaimed CI parity guarantee, and an unfalsifiable Hard Limit 1. Three unrelated session-hygiene gaps were filed alongside. All nine items (one discovered and fixed mid-run) shipped together as a single wave, per explicit human direction overriding the initially-recommended multi-wave split:

- **README accuracy** — removed the drift-prone Count column, described folders by category instead of enumerating members, fixed the `feature-structure.md` path (`plan/`, not `planifest-framework/`) and the `planifest-docs/` vs `docs/` mismatch in the structure diagram. Discovered mid-implementation that 5 folders (`scripts/`, `tests/`, `external-skills/`, `migrations/`, `skills-inbox/`) had no table row at all — added them so the new drift check (below) starts from a clean baseline.
- **component.yml matcher fix** — `.github/workflows/planifest.yml`, `planifest-framework/hooks/planifest.yml`, `hooks/pre-push`, and `hooks/pre-commit` all matched against `component.json`, a filename that doesn't exist; the real manifest is `component.yml`. This was a false-rejection bug, not an enforcement hole. Two new tests assert both directions against the shipped hooks directly.
- **Honest CI parity wording** — the parity check proves a file under `plan/`/`docs/`/`component.yml` changed, not that it corresponds to the code change. Error messages and the README now say so.
- **Hard Limit 1 reworded** — "Requirements must be complete before codegen begins" was unfalsifiable; reworded to the actual enforceable behaviour (gaps surfaced, resolved or deferred, checkable via `scope.md`).
- **New self-description CI check** — `planifest-framework/scripts/self-description-check.mjs`, wired into a new CI job, verifies every README structure-diagram path exists and every `planifest-framework/` folder has a table row. Deliberately a separate script from `consistency-check.mjs` (ADR-001) — different subject, different lifecycle.
- **Timestamped design confirmations** — `design.template.md`'s Confirmation section now carries a local timestamp and timezone, `//`-delimited from the yes/no.
- **Orchestrator context hygiene** — `/clear` (or a flag to the human) at Phase 0 start and P9 completion, plus new advisory dynamic-compaction guidance.
- **Backlog ID sequence convention documented** — stated explicitly in the template and the orchestrator's P0 pickup step that backlog IDs are their own sequence, independent of feature IDs, and collisions are expected (this very feature collided in number with backlog entry `0000019-populate-regression-pack`).
- **Telemetry hook fix (discovered and fixed in P0)** — `context-pressure.mjs` sent `phase: "monitoring"`, not a member of the telemetry backend's `phase` enum; every emission failed with HTTP 400, unconditionally, in any environment. Fixed to `phase: "orchestrator"` (ADR-002), verified live against the running backend (400 → 200).

Backlog item `0000013` (setup refresh skill) was explicitly deferred to next release, not discarded. Backlog items `0000019`–`0000025` (regression pack, orchestrator decomposition, minimal artifact set, token accounting, baseline comparison, skill-scope ADR, adoption position) remain untouched, several with explicit dependency ordering already noted in their own entries.

## Artifacts Produced

- `plan/current/` (now archived): design, feature-brief, discovery, 8 requirement files, execution-plan, scope, risk-register (5 risks + 3 assumptions), domain-glossary (8 terms), 2 ADRs, security-report (risk Low, 1 low finding), recommendations, build-log
- `README.md`, `.github/workflows/planifest.yml`, `planifest-framework/hooks/planifest.yml`, `planifest-framework/hooks/pre-push`, `planifest-framework/hooks/pre-commit`
- `planifest-framework/scripts/self-description-check.mjs` (new), 2 new test files (`test-0000019-req-002-component-yml-matcher.sh`, `test-0000019-req-005-self-description-check.sh`), 1 fixed pre-existing test assertion (`test-context-pressure.sh`)
- `planifest-framework/skills/planifest-orchestrator/SKILL.md`, `planifest-framework/templates/design.template.md`, `planifest-framework/templates/backlog-entry.template.md`
- `planifest-framework/hooks/telemetry/context-pressure.mjs`
- `planifest-framework/component.yml` (version bump)
- Living docs: `docs/about.md` (v0.19.0), `docs/component-registry.md`, `docs/decisions-index.md` (+2 ADRs)

## Decisions

- ADR-001 (this feature): repository self-description check is a new, separate script, not an extension of `consistency-check.mjs`
- ADR-002 (this feature): `context_pressure` telemetry events map to `phase: "orchestrator"`

## Security

No critical or high findings. Overall risk Low. One low finding (unanchored `component.yml` regex — pre-existing, not introduced by this feature).

## Skipped Phases

None.

## Process Notes

Two process gaps were self-caught and corrected within this same run rather than left silent: an initial P0 commit landed directly on `main` instead of the `feat/` branch (caught immediately, `main` reset, commit moved to the correct branch), and P4 validation work began before its build-log phase-start block was written (Hard Limit 8 — caught and corrected before the phase gate). Both are recorded in full in the archived `build-log.md`.
