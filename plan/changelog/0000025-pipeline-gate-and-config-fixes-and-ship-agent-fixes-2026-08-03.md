# Changelog — 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes — 03 Aug 2026

**Feature:** Pipeline gate and config fixes, and ship-agent fixes
**Pipeline run:** P0–P9 complete, no phases skipped
**PR:** https://github.com/planifest/planifest-framework/pull/51

## What Was Built

A bundle of 7 small, independently-discovered defects in the Planifest pipeline's own tooling, picked up from `plan/backlog/` at P0 and confirmed as one pipeline run:

1. Ship-agent's PR description template no longer hardcodes an AI-attribution footer — omitted by default, restorable only via a `planifest-overrides/instructions/` opt-in.
2. Ship-agent's P7 Step 7 `git add` now explicitly stages `plan/current/`, no longer relying on git's rename-detection heuristic.
3. Subagent parallelism directives extended to `agent-dispatch-standards.md`, `planifest-validate-agent`, and `planifest-docs-agent` for independent new-test-files and living-doc edits.
4. Setup scripts now additionally write a versioned, git-tracked `planifest-overrides/setup-config/{tool}.md` alongside the existing gitignored `.planifest-setup-flags` marker.
5. `planifest-docs-agent` now routes `recommendations.md`'s Deferred Items/Tech Debt rows into `plan/backlog/` entries tagged by source, going forward.
6. `planifest-docs-agent`'s Gate B (and other phase skills, audited) now respect `continuous_run` before stopping for confirmation.
7. The Scope Lock Challenge now defaults to drafting all four scenario-path answers up front in parallel and presenting them as one batch, superseding `0000017-ADR-003`.

## Artifacts Produced

`feature-brief.md`, `design.md`, `discovery.md`, `execution-plan.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`, `operational-model.md`, `slo-definitions.md`, `cost-model.md`, 7 requirement docs (`requirements/req-001` through `req-007`), 3 ADRs (`adr/ADR-001` through `ADR-003`), `security-report.md`, `recommendations.md`, `build-log.md`.

## Decisions

- **ADR-001:** Ship-agent PR footer defaults off; restorable only via a `planifest-overrides/instructions/` opt-in file.
- **ADR-002:** `planifest-overrides/setup-config/{tool}.md` (tracked) is source of truth over the gitignored `.planifest-setup-flags` marker; reconciled on setup/refresh.
- **ADR-003:** Scope Lock Challenge defaults to always-drafted, batch-presented answers — supersedes `0000017-ADR-003`, scoped narrowly against `0000014-ADR-008`.

## Skipped Phases

None.
