---
title: "Discovery - 0000021-framework-context-bloat-audit"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000021-framework-context-bloat-audit

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.
> Fresh each pipeline run: filed to the archive at P7, recreated at the next P0.
> A section whose signal could not be read states that plainly — coaching proceeds on the rest.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `Standard Iterative` |
| Detection signal | `plan/_archive/` contains 20 prior feature dirs; `docs/about.md` exists at v0.20.0 |
| Git pre-flight | Branch `main`, working tree clean, human confirmed main up to date and all previous PRs merged; branched to `feat/0000021-framework-context-bloat-audit` |
| Skills inbox | `planifest-framework/skills-inbox/` — empty |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.20.0`
- Prior features (`plan/_archive/`): `0000001-context-mode-enforcement-hooks`, `0000002-structured-telemetry-framework-integration`, `0000003-hook-based-enforcement-2026-04-20`, `0000004-tdd-regression-test-quality-2026-05-01`, `0000005-framework-governance-2026-05-02`, `0000006-build-assessment-phase-2026-05-03`, `0000007-agent-optimisation-2026-05-04`, `0000008-context-mode-plugin-routing-rules-2026-05-09`, `0000009-framework-rail-tightening-2026-05-12`, `0000010-framework-quality-improvements`, `0000011-setup-parity-and-consistency-2026-05-17`, `0000012-docs-restructure-commit-directives-2026-05-18`, `0000013-codegen-component-version-bump-2026-05-18`, `0000014-improve-adoption-mode-selection-2026-05-19`, `0000015-pipeline-session-cleanup-2026-05-19`, `0000016-pipeline-governance-and-loop-engineering-2026-07-11`, `0000017-ratchet-forgery-detection-and-telemetry-schema-spec-2026-07-26`, `0000018-telemetry-emission-consistency-2026-07-31`, `0000019-self-description-and-session-hygiene-fixes-2026-07-31`, `0000020-setup-refresh-skill-2026-08-01`, `backlog-triage-2026-07-11`. Not individually re-read in full for this pass; folder names are self-describing one-liners. Most directly relevant prior work by subject: `0000007-agent-optimisation`, `0000009-framework-rail-tightening`, `0000010-framework-quality-improvements` (all previously trimmed/tightened framework instruction content and set the Engineering Layer convention for meta-features that touch `planifest-framework` itself rather than application code).
- Constraining ADRs (unless superseded): not individually enumerated in this pass — `plan/_archive/*/adr/` was not read in full. P2 will surface any ADR that directly constrains skill/instruction content and cite it explicitly rather than relying on this discovery pass.
- Component / data-ownership map (`docs/`): `docs/component-registry.md` — single relevant entry `planifest-framework` (component-pack, domain `developer-tooling`, status `active`), owning all skills/, templates/, standards/, hooks/, setup scripts under `planifest-framework/`.

## Backlog Pickup (P0 step 3c)

Ten entries scanned in `plan/backlog/`. Human decisions, recorded here for traceability (full Q&A in `build-log.md`):

| Entry | Decision | Note |
|-------|----------|------|
| `0000019-populate-regression-pack` | **Pulled in** | Folded into this feature's scope as a prerequisite; folder deleted. |
| `0000020-decompose-orchestrator-skill` | Left | Human: structural router/references decomposition is easier once general bloat is removed first — separate future feature. |
| `0000021-define-minimal-artifact-set` | Left | Different axis — per-run artifact obligations, not skill-instruction bloat. |
| `0000022-add-token-accounting-per-phase` | Left | Unrelated. |
| `0000023-publish-baseline-comparison` | Left | Unrelated. |
| `0000024-record-skill-scope-principle-adr` | Left | Human: easier to write the governing-test ADR after general bloat is removed. |
| `0000025-declare-adoption-position-and-stability-policy` | Left | Unrelated. |
| `0000026-ai-writing-tells-style-guard` | Left | Unrelated (generated-prose style, not instruction-content size/redundancy). |
| `0000027-setup-sh-copilot-broken-self-copy` | Left | Unrelated (pre-existing bug). |
| `0000028-orchestrator-markers-not-committed-before-pr` | Left | Unrelated (process gap). |

## Size Baseline (framework instruction-content footprint)

Gathered via shell scan, for use as the audit's before/after measurement baseline:

| Path | Size |
|------|------|
| `planifest-framework/skills/` | 256K, 21 `SKILL.md` files, 3,959 total lines |
| `planifest-framework/templates/` | 188K |
| `planifest-framework/standards/` | 448K |
| `planifest-framework/skills/planifest-orchestrator/SKILL.md` | 1,195 lines — largest single file, ~30% of all skill-file lines |
| `CLAUDE.md` | 51 lines |

Per-skill line counts (ascending): scope-lock-agent 54, verify-by-execution 60, reversal-assessor 69, design-critic 71, implementer 89, refactor 89, loop-runner 93, test-writer 93, optimise-agent 101, adr-agent 102, migrator 104, spec-agent 136, security-agent 146, build-assessment-agent 165, refresh-setup 169, validate-agent 181, change-agent 195, docs-agent 222, ship-agent 310, codegen-agent 315, orchestrator 1,195.
