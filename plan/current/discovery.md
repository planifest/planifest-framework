---
title: "Discovery - 0000019-framework-review-fixes"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000019-framework-review-fixes

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.
> Fresh each pipeline run: filed to the archive at P7, recreated at the next P0.
> A section whose signal could not be read states that plainly — coaching proceeds on the rest.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `Standard Iterative` |
| Detection signal | `plan/_archive/` contains 18 prior feature directories; `docs/about.md` exists (priority 2 signal; no `planifest-overrides/instructions/external-versioning.md` present, so priority 1 does not apply) |
| Git pre-flight | branch `main`, working tree clean; main-up-to-date confirmation still pending human answer (no remote access — `git pull` not attempted per `planifest-overrides/instructions/custom-001-local-git-only.md`) |
| Skills inbox | empty |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.18.0`, last feature `0000018-telemetry-emission-consistency`, updated `31 Jul 2026`
- Prior features (`plan/_archive/`): 0000001-context-mode-enforcement-hooks, 0000002-structured-telemetry-framework-integration, 0000003-hook-based-enforcement-2026-04-20, 0000004-tdd-regression-test-quality-2026-05-01, 0000005-framework-governance-2026-05-02, 0000006-build-assessment-phase-2026-05-03, 0000007-agent-optimisation-2026-05-04, 0000008-context-mode-plugin-routing-rules-2026-05-09, 0000009-framework-rail-tightening-2026-05-12, 0000010-framework-quality-improvements, 0000011-setup-parity-and-consistency-2026-05-17, 0000012-docs-restructure-commit-directives-2026-05-18, 0000013-codegen-component-version-bump-2026-05-18, 0000014-improve-adoption-mode-selection-2026-05-19, 0000015-pipeline-session-cleanup-2026-05-19, 0000016-pipeline-governance-and-loop-engineering-2026-07-11, 0000017-ratchet-forgery-detection-and-telemetry-schema-spec-2026-07-26, 0000018-telemetry-emission-consistency-2026-07-31; plus one triage archive `backlog-triage-2026-07-11`. Note: these are feature-sequence IDs, a separate monotonic sequence from `plan/backlog/` entry IDs (0000011-0000026) — the two sequences are expected to collide on number, per the very convention backlog item 0000026 in this batch documents.
- Constraining ADRs (unless superseded): `ADR-001-backlog-folder-not-editable-lifecycle.md` (feature 0000016) directly bears on 0000026 — backlog folders are lifecycle-managed (pull-in/leave/discard), not freely editable; this batch's 0000026 item documents the ID-sequence convention without altering that lifecycle. No other archived ADR was found to constrain the README/CI/hook-wording/orchestrator-format items in this batch.
- Component / data-ownership map (`docs/`): `docs/component-registry.md` and `docs/architecture-overview.md` exist but are not applicable — this batch touches framework-authoring artifacts (README, CI workflow, shipped hooks, orchestrator skill, templates), not application `src/` components with data ownership.
