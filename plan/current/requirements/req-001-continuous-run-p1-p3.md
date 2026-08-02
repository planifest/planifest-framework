---
title: "Requirement: req-001 - continuous-run-p1-p3"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-001 - continuous-run-p1-p3

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Source:** US-001
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As a human on the loop running continuous mode, I want P1 (Spec), P2 (ADRs), and P3 (Codegen) to skip the confirmation stop the same way P4-P6 already do, so that continuous_run behaves as previously verified in features 0000019 and 0000020.

## Functional Requirements

- Change the STOP-rule cell text for the P1, P2, P3 rows of the Phase Invocation Table (planifest-framework/skills/planifest-orchestrator/SKILL.md, currently around line 502-513) to the exact wording below, leaving every other cell in those rows unchanged:
  - P1 Requirements: `STOP, present requirement count/scope decisions/deferred items. Exception: continuous_run: true was set at P0.`
  - P2 Architecture Decisions: `STOP, present ADR list with one-line summaries. Exception: continuous_run: true was set at P0.`
  - P3 Code Generation: `STOP, present components built/tests produced/deviations. Exception: continuous_run: true was set at P0.`
- Leave the P4, P5, P6, and P9 rows of the Phase Invocation Table byte-for-byte unchanged — they already implement the continuous_run exception correctly and must not be touched.
- Produce an ADR at P2 (by planifest-adr-agent, not by this requirement doc) recording: what broke, the root cause, and the corrected behavior. See Dependencies.

## Acceptance Criteria

- [x] P1, P2, P3 STOP-rule cells in the Phase Invocation Table read exactly as specified above — covered by `planifest-framework/tests/test-0000023-req-001-continuous-run-p1-p3.sh`
- [x] P4, P5, P6, P9 STOP-rule cells are byte-identical to their current state — covered by the same test's "P4-P6/P9 unchanged" section
- [x] An ADR exists (post-P2) documenting the regression's root cause and the fix — `plan/current/adr/ADR-001-restore-continuous-run-p1-p3.md`
- [x] A fresh continuous_run pipeline run demonstrates P1, P2, P3 proceeding without a confirmation stop — this pipeline run (0000023) is the live verification: P1, P2, P3 all proceeded without a human confirmation stop under continuous_run

## Dependencies

- References an ADR to be produced in P2 by planifest-adr-agent, documenting the regression (introduced in commit 42ae808, feature 0000021-framework-context-bloat-audit, which silently dropped the continuous_run escape hatch that was in effect through features 0000019 and 0000020's actual runs) and the corrected behavior restored by this requirement. No other component dependency.

## Background (context, not a template section — retained for traceability)

The "No exception" wording currently in the P1/P2/P3 STOP-rule cells was introduced in commit 42ae808 (feature 0000021-framework-context-bloat-audit, a word-count trim pass) which silently dropped the continuous_run escape hatch present before it (confirmed via `git show 1eec013:planifest-framework/skills/planifest-orchestrator/SKILL.md`). The escape hatch was in effect through 0000019 and 0000020's actual runs, per their build logs at plan/_archive/0000019-*/build-log.md and plan/_archive/0000020-*/build-log.md, both showing continuous_run correctly skipping the P1-P3 stops. Feature 0000022 only consolidated the already-broken wording into the current table format — it did not introduce the bug. This requirement is a regression fix, not a fresh design decision.
