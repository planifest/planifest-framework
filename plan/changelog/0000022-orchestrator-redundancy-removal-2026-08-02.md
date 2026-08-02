# Changelog — 0000022-orchestrator-redundancy-removal — 02 Aug 2026

**Feature:** Orchestrator Redundancy Removal
**Pipeline run:** P0-P9 complete, no phases skipped
**PR:** https://github.com/planifest/planifest-framework/pull/47

## What Was Built

Removed content from `planifest-framework/skills/planifest-orchestrator/SKILL.md` that was already fully and correctly stated in a phase skill, workflow, standard, or template, replacing each with a one-line pointer. Relocated the Model Tier Decision Table and Parallelism Rules + Agent Dispatch Template into a new `planifest-framework/standards/agent-dispatch-standards.md`, the canonical home referenced by the orchestrator and codegen-agent. Trimmed non-operative expository asides. Verified the trim was lossless via a dual-detector process (0000022 ADR-002): the regression pack, plus an independent fresh-context P4 diff review that caught and fixed one genuine content-loss finding (the External Anchor mode's underlying-mode selection mapping) before ship.

Result: the orchestrator shrank from 10,379 to 8,592 words (-17.2%), with zero behavioural change and zero regression-pack failures across 55 tests. The original 7,600-word target was revised to 8,600 with the human's explicit confirmation after review found the remaining size to be dense P0 operative content, not duplication.

## Artifacts Produced

- `plan/current/discovery.md`, `feature-brief.md`, `design.md` (P0)
- `plan/current/execution-plan.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`, `operational-model.md`, `slo-definitions.md`, `cost-model.md`, `requirements/req-001` through `req-005` (P1)
- `plan/current/adr/ADR-001-agent-dispatch-standards-file.md`, `ADR-002-dual-detector-content-loss-verification.md` (P2)
- `plan/current/regression-baseline.md` (baseline + post-trim comparison, P3/P5)
- `plan/current/security-report.md` (P5)
- `plan/current/recommendations.md` (P6)
- `planifest-framework/standards/agent-dispatch-standards.md` (new file)
- Updated: `planifest-framework/skills/planifest-orchestrator/SKILL.md`, `planifest-scope-lock-agent/SKILL.md`, `planifest-codegen-agent/SKILL.md`, `planifest-spec-agent/SKILL.md`
- Updated: `planifest-framework/standards/telemetry-standards.md`, `planifest-framework/workflows/retrofit.md`, `planifest-framework/workflows/fast-path.md` (unchanged, confirmed canonical), `planifest-framework/templates/discovery.template.md`
- Updated: `planifest-framework/component.yml` (0.21.0 → 0.22.0), `docs/component-registry.md`
- Test corrections (relocation-aware, none deleted or weakened): `planifest-framework/tests/test-0000006-build-assessment.sh` and its `tests/regression/` copy, `test-0000010-framework-quality-improvements.sh`, `test-0000017-req-006-structured-discovery-pass.sh` and its `tests/regression/` copy
- `planifest-overrides/instructions/custom-002-prefer-subagent-decomposition.md` (standing instruction added mid-run, human-directed)
- Backlog filed: `0000029-scope-lock-drafts-always-presented`, `0000030-mandate-marker-commit-at-creation`

## Decisions

- **ADR-001** (this feature): create `standards/agent-dispatch-standards.md` as the canonical home for model-tier and parallelism/dispatch reference data, relocated byte-for-byte from the orchestrator; orchestrator and codegen-agent point to it (ship-agent had no duplicate to begin with — correction to the ADR's assumed scope).
- **ADR-002** (this feature): verify zero enforcement-content loss with two detectors — the regression pack (10 of 22 tests pin orchestrator content) and a mandatory, independently-dispatched P4 diff review for everything the pack doesn't pin. Both resolve a finding by restoring or relocating, never by rationalising it away.

## Skipped Phases

None.
