# Changelog — 0000023-framework-pipeline-fixes — 02 Aug 2026

**Feature:** Framework Pipeline Fixes
**Pipeline run:** P0-P9 all completed, none skipped
**PR:** pending — updated after PR description is output in Step 10

## What Was Built

A batch of 4 independently-filed, small correctness fixes to the Planifest framework's own pipeline tooling, picked up together from `plan/backlog/` at P0:

1. **Restored `continuous_run` for P1-P3.** The Phase Invocation Table's P1/P2/P3 STOP rules hardcoded "No exception," silently overriding the human's continuous_run choice at P0 — restored to match P4-P6's working behavior. Root-caused via git history to commit `42ae808` (feature 0000021, a word-count trim pass), not feature 0000022 as the filing backlog entry (0000031) originally claimed.
2. **Fixed session-marker commit lifecycle.** Markers (`plan/.orchestrator-active`, `plan/.orchestrator-ack`, `plan/.run-mode`) are now committed at the point they're written in P0, and their deletion at P7 is staged atomically with the archive commit; a new P9 pre-flight check catches any future regression of the atomic fix.
3. **Fixed `setup.sh`/`setup.ps1` copilot crash.** `copilot.sh`'s `TOOL_HOOK_ADAPTER_DEST` resolved to the same path as its source, crashing `cp` under `set -euo pipefail` on every invocation. Fixed on both `.sh` and `.ps1`, plus an additional `setup.ps1` dispatcher-guard bug found during investigation (would have called `Install-Tier1HookRegistration` with a null `SettingsFile` for Copilot).
4. **Added `product_id` telemetry emission.** The 3 telemetry hooks and the canonical envelope template now populate `product_id` (git repo root, falling back to cwd), closing a gap left by `structured-telemetry-mcp`'s own feature 0000015.

This pipeline run also served as a live dogfood of fixes 1 and 2: P1-P4 all proceeded under `continuous_run` without a forced stop, and this run's own session markers were committed at creation and (about to be) deleted atomically at this archive step.

## Artifacts Produced

- `plan/current/feature-brief.md`, `design.md`, `discovery.md`
- `plan/current/execution-plan.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`, `operational-model.md`, `slo-definitions.md`, `cost-model.md`
- `plan/current/requirements/req-001` through `req-004`
- `plan/current/adr/ADR-001-restore-continuous-run-p1-p3.md`
- `plan/current/security-report.md`, `recommendations.md`
- Code: `planifest-framework/skills/planifest-orchestrator/SKILL.md`, `planifest-framework/skills/planifest-ship-agent/SKILL.md`, `planifest-framework/setup/copilot.sh`, `planifest-framework/setup/copilot.ps1`, `planifest-framework/setup.ps1`, `planifest-framework/hooks/telemetry/{emit-phase-start,emit-phase-end,context-pressure}.mjs`, `planifest-framework/standards/telemetry-standards.md`, `planifest-framework/component.yml`
- Tests: 4 new test files under `planifest-framework/tests/` (req-001 through req-004)
- Docs: `docs/component-registry.md`, `docs/decisions-index.md`, `docs/architecture-overview.md`

## Decisions

- **ADR-001:** Restore the `continuous_run` exception to P1/P2/P3 STOP rules, matching P4-P6's existing mechanism; root-caused to commit `42ae808` (feature 0000021), correcting backlog 0000031's incomplete attribution.

## Skipped Phases

None.
