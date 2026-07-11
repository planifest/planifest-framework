# Changelog — 0000016-pipeline-governance-and-loop-engineering — 11 Jul 2026

**Feature:** Pipeline Governance and Loop Engineering
**Pipeline run:** P0–P9 completed, no phases skipped (continuous run authorized at design confirmation; P7 ship gate human-confirmed)
**PR:** pending — human raises PR (local-git-only; no per-session push grant)

## What Was Built

Three related governance gaps closed in one feature, plus the loop-engineering layer:

- **Backlog mechanism** — `plan/backlog/{id}-{slug}/` gives discovered-but-out-of-scope work a durable, human-reviewed home surfaced at every subsequent P0 (pull-in / leave / discard), replacing scope-creep and silent drops. Explicitly chosen over the rejected editable-P7–P9 lifecycle: P7 stays the lock line.
- **Product-level versioning** — root `product.yml` with `versionPolicy` (`max-component-version` | `explicit` | `external`) gives multi-component projects a defined P9 tagging story; `scripts/product-version.mjs` derives it deterministically; single-component projects (this repo) keep `component.yml` behaviour byte-identical.
- **Loop engineering (all toggles default off)** — `planifest-loop-runner` (canonical state/run-log/stop-rule mechanics), `planifest-design-critic` (fresh-context REJECT-default critique of P1/P2 + deterministic `consistency-check.mjs`), governed reversal protocol (defect report → `planifest-reversal-assessor` DENY-default verdict → scoped correction with invalidation cascade, budget 2/feature), `ratchet-check.mjs` hook blocking silent criteria/scope weakening, `planifest-verify-by-execution` (P4 verifies criteria by running the software), and the cross-model review gate at end of P6 (strictly pre-archive).
- **Commit/push discipline** — Hard Limit 7 strengthened to per-meaningful-artifact commits with push cadence when authorized; this run itself shipped as ~35 granular commits.
- **Terminology** — decomposition "Phase" renamed "Wave" (brief template, orchestrator, spec-agent), ending the collision with P0–P9.

## Artifacts Produced

- `plan/current/`: feature-brief, design, 21 requirement files, execution-plan, scope, risk-register (10 risks), domain-glossary (25 terms), operational-model, slo-definitions, cost-model, 8 ADRs, security-report (risk Low), verification-report, recommendations, build-log
- `planifest-framework/`: 6 templates (backlog-entry, product, loop-state, defect-report, revision-log, loop-toggles), 4 skills (loop-runner, design-critic, reversal-assessor, verify-by-execution), `hooks/enforcement/ratchet-check.mjs`, `scripts/consistency-check.mjs`, `scripts/product-version.mjs`, setup.sh wiring, orchestrator/ship/validate/spec skill updates, commit directive in 6 phase skills, telemetry-standards loop events, component.yml 0.16.0
- `plan/backlog/0000001-flaky-test-suite-sigpipe/` — first live backlog entry (pre-existing macOS-only test flakiness)
- Living docs: component-registry, decisions-index (+8 ADRs), architecture-overview (governance-loop layer)

## Decisions

- ADR-001: backlog folder instead of editable post-archive lifecycle — P7 stays locked
- ADR-002: `product.yml` + three-value `versionPolicy`, ship-agent writes / orchestrator reads
- ADR-003: loop toggles live in user-owned `planifest-overrides/loop-toggles.yml`; absent = off
- ADR-004: single-use human-written `.ratchet-approve` marker is the only path past the ratchet
- ADR-005: reversal cascades >3 artifacts always stop for the human
- ADR-006: verifiers are fresh-context REJECT-default subagents (maker–checker)
- ADR-007: caps (3 default; P4 keeps 5), budget (2/feature), and ratchet enforced deterministically, never by prose
- ADR-008: cross-model review gate at end of P6, strictly before P7 archive

## Skipped Phases

None.
