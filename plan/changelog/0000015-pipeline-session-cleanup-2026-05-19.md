# Changelog — 0000015-pipeline-session-cleanup — 19 May 2026

**Feature:** Pipeline Session Cleanup
**Pipeline run:** P0, P1, P2, P3, P4, P5, P6, P7, P8, P9 — none skipped
**PR:** pending — updated after PR is raised

## What Was Built

Six targeted fixes to the Planifest pipeline to ensure clean session state across features:

1. Build log phase blocks now written before every phase P0–P9 (REQ-001)
2. Ship-agent Step 6 deletes `plan/.run-mode` at P9 so the next P0 always asks fresh (REQ-002)
3. Orchestrator P0 pre-flight detects stale `plan/.run-mode` on fresh start and auto-clears with a visible warning (REQ-003)
4. Ship-agent Step 11 emits a new-session recommendation after P9 completes (REQ-004)
5. Version suggestion wording changed to "Last known version: X" for clarity (REQ-005)
6. Orchestrator resume detection gains an interrupted P9 branch — `.orchestrator-active` present AND `plan/current/` empty triggers sentinel cleanup (REQ-006)

## Artifacts Produced

- `plan/current/design.md`
- `plan/current/feature-brief.md`
- `plan/current/execution-plan.md`
- `plan/current/scope.md`
- `plan/current/risk-register.md`
- `plan/current/domain-glossary.md`
- `plan/current/operational-model.md`
- `plan/current/slo-definitions.md`
- `plan/current/cost-model.md`
- `plan/current/requirements/req-001-build-log-all-phases.md`
- `plan/current/requirements/req-002-clear-run-mode-p9.md`
- `plan/current/requirements/req-003-stale-run-mode-check.md`
- `plan/current/requirements/req-004-recommend-new-session.md`
- `plan/current/requirements/req-005-version-wording.md`
- `plan/current/requirements/req-006-interrupted-p9-resume.md`
- `plan/current/adr/ADR-001-interrupted-p9-detection-signal.md`
- `plan/current/adr/ADR-002-new-session-recommendation-not-block.md`
- `plan/current/adr/ADR-003-stale-run-mode-warn-and-clear.md`
- `plan/current/adr/ADR-004-run-mode-deletion-at-p9.md`
- `plan/current/build-log.md`

## Decisions

- **ADR-001:** Interrupted P9 detected by combined signal (empty plan/current/ + .orchestrator-active present) — no dedicated flag file needed
- **ADR-002:** New session recommendation is advisory only — human retains control, no hard block
- **ADR-003:** Stale run-mode at P0 triggers warn-and-clear, not a hard block — self-healing behaviour
- **ADR-004:** P9 owns run-mode deletion; P0 handles recovery case only — clear single ownership

## Skipped Phases

None
