---
title: "Discovery - 0000027-backlog-batch-governance-tooling-fixes"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000027-backlog-batch-governance-tooling-fixes

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.
> Unreadable signal: say so; coaching proceeds.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `standard-iterative` |
| Detection signal | `docs/about.md` exists (version `0.26.1`, last feature `0000026`) AND `plan/_archive/` has 26 prior feature runs. Highest-priority applicable signal — no `planifest-overrides/instructions/external-versioning.md` present. |
| Git pre-flight | Branch `main` confirmed up to date by human on the loop (all previous PRs merged). `feat/0000027-backlog-batch-governance-tooling-fixes` cut from `main` once feature ID was confirmed at resume. |
| Skills inbox | `planifest-framework/skills-inbox/` — empty. |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.26.1`, last feature `0000026-context-hook-and-telemetry-backstop-fixes`. `product.yml` (product-level, takes precedence per ADR-002) agrees: `0.26.1`, `versionPolicy: max-component-version`, `id: planifest-framework` already declared (no P0 hard-stop needed).
- Prior features (`plan/_archive/`, 26 runs): `0000001-context-mode-enforcement-hooks` … `0000026-context-hook-and-telemetry-backstop-fixes` (full chronological list; folder names are self-describing one-liners). Most recent five: `0000022-orchestrator-redundancy-removal`, `0000023-framework-pipeline-fixes`, `0000024-declared-product-id-for-telemetry`, `0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes`, `0000026-context-hook-and-telemetry-backstop-fixes`.
- Constraining ADRs (unless superseded): `0000016-ADR-002` (product.yml as versioning source of truth), `0000016-ADR-007` (deterministic caps/budget/ratchet enforcement — "never skill prose alone", directly relevant to backlog `0000044`'s telemetry-backstop ask), `0000017-ADR-003` (Scope Lock Challenge always-drafted/batch-presented default), `0000018-ADR-001` (unified telemetry signal — one gate flag for all telemetry hooks, relevant to backlog `0000043`), `0000018-ADR-002` (telemetry failure-marker detection protocol, relevant to backlog `0000044`), `0000014-ADR-008` (one-question-at-a-time coaching convention, narrow Scope-Lock exception only).
- Component / data-ownership map (`docs/component-registry.md`): three active components, all `developer-tooling` domain — `planifest-framework` (core standards/skills/hooks/setup, owns its own docs), `setup-hook-integration` (setup.sh/ps1, tool adapters incl. `cline.sh`/`cline.ps1` — owns backlog `0000034`'s fix target), `context-mode-hooks` (blocking PreToolUse enforcement scripts). No shared-write conflicts among the 8 targeted backlog items — all touch `planifest-framework` skill/hook/doc content or `setup-hook-integration`'s `cline.sh`, never both in a way that crosses ownership.

## Targeted Batch (8 backlog items, confirmed scope per prior-session build-log)

| ID | One-liner | Primary component |
|----|-----------|--------------------|
| `0000043` | phase_start/phase_end telemetry hooks never wired into setup.sh/ps1 despite scripts existing | setup-hook-integration |
| `0000034` | `cline.sh` boot-file/skills-dir path collision aborts `setup.sh` under `set -euo pipefail` | setup-hook-integration |
| `0000035` | Dispatched subagents should file out-of-scope discoveries to `plan/backlog/`, not host-tool `spawn_task` | planifest-framework (orchestrator + phase-skill dispatch guidance) |
| `0000044` | Orchestrator misses telemetry failure markers at phase boundaries; never makes agent-driven `emit_event` calls | planifest-framework (orchestrator conduct + backstop mechanism) |
| `0000045` | Backfill pre-0000025 `recommendations.md` deferred items into `plan/backlog/` | planifest-framework (one-time migration) |
| `0000046` | No explicit P0 handling distinguishing a `planifest-framework/` dependency update from an arbitrary code push | planifest-framework (P0 flow + governance doc) |
| `0000024` | Record an ADR for the "does this skill earn its place" governance test | planifest-framework (ADR only) |
| `0000021` | `feature-pipeline.md` mandates cost model/SLOs/ops model for every feature regardless of size — define a minimal artifact set | planifest-framework (workflow + spec-agent) |

**Migration check (already resolved before this P0 run):** `migrate-product-yml-component-paths.md` checked against Resume Detection's pending-migration scan — `product.yml`'s `components[]` already used `{id, path}`, 0 corrections needed, archived to `planifest-framework/migrations/_done/`, committed. `node planifest-framework/scripts/product-version.mjs` returned `0.26.1`, exit 0. No pending migrations remain.
