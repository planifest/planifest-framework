---
title: "Discovery - 0000022-orchestrator-redundancy-removal"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000022-orchestrator-redundancy-removal

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.
> Unreadable signal: say so; coaching proceeds.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `standard-iterative` |
| Detection signal | `plan/_archive/` contains 21 feature dirs AND `docs/about.md` exists (priority-2 signal; no `external-versioning.md`) |
| Git pre-flight | Branch `feat/0000022-orchestrator-redundancy-removal` created from `main` at `42ae808`; human confirmed all PRs merged and main pulled up to date at session start; working tree clean |
| Skills inbox | empty |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.21.0` (last feature: `0000021-framework-context-bloat-audit`, 01 Aug 2026)
- Prior features (`plan/_archive/`): 21 features, `0000001` through `0000021`, plus a backlog triage (2026-07-11). Most recent and most relevant to this feature:
  - `0000021-framework-context-bloat-audit` (2026-08-01): guardrailed trim across skills (-22.4%), standards (-43.2%), templates (-28.1%); populated the regression pack from 1 test to 22; orchestrator explicitly excluded from structural decomposition, trimmed line-level only (12,204 -> 10,379 words)
  - `0000020-setup-refresh-skill` (2026-08-01): setup refresh skill; introduced `.planifest-setup-flags` marker
  - `0000019-self-description-and-session-hygiene-fixes` (2026-07-31)
  - `0000018-telemetry-emission-consistency` (2026-07-31): unified telemetry signal, failure markers, per-phase `Telemetry` build-log line
  - `0000016-pipeline-governance-and-loop-engineering` (2026-07-11): loop-runner, toggles, reversal protocol, maker-checker review gates
- Constraining ADRs (unless superseded):
  - `0000021/ADR-002` guardrailed baseline-gated trim process: any trim of framework instruction files requires a regression-pack baseline run before edits and a comparison re-run after; zero enforcement-content loss is the pass condition. Directly binds this feature.
  - `0000018/ADR-001` unified telemetry signal and `ADR-002` failure-is-never-silent: constrain how the Telemetry build-log line is recorded (this run: confirmed-disabled).
  - `0000016/ADR-003` (toggle defaults), `ADR-006` (fresh-context maker-checker review), `ADR-007` (deterministic loop enforcement): constrain how review gates and any loops in this run behave.
- Component / data-ownership map (`docs/`): 3 components, all `component-pack` / developer-tooling / active:
  - `planifest-framework` (v0.21.0): standards, skills, hooks, setup scripts - the component this feature modifies
  - `setup-hook-integration` (v0.4.0): setup.sh/ps1, skill-sync, hook adapters
  - `context-mode-hooks`: blocking PreToolUse hook scripts
  No databases; no runtime data ownership concerns for this feature.

### Feature-specific discovery (redundancy examination, this session)

Cross-reference of `planifest-framework/skills/planifest-orchestrator/SKILL.md` (10,379 words, 944 lines) against the canonical owners of overlapping content:

| Orchestrator content | Canonical owner confirmed |
|---|---|
| Telemetry event table + JSON snippets (667 words) | `standards/telemetry-standards.md` |
| Per-phase Input/Produces/Gate blocks P1-P7 (~1,040 words) | Each phase skill's own SKILL.md (spec, adr, codegen, validate, security, docs, ship) |
| Fast Path criteria + execution (~200 words) | `workflows/fast-path.md` |
| Scope Lock suggested-answer protocol detail (~250 words) | `skills/planifest-scope-lock-agent/SKILL.md` |
| Reversal execute/assess mechanics (~170 words) | `skills/planifest-reversal-assessor/SKILL.md`, `skills/planifest-loop-runner/SKILL.md` |
| Retrofit scan + per-mode discovery content (~280 words) | `workflows/retrofit.md`, `templates/discovery.template.md` |
| Change Pipeline confirm questions (~40 words) | `workflows/change-pipeline.md` |
| Model Tier Decision Table (314 words, stale model ids, duplicated in ship-agent) | No canonical home yet - candidate new standards file |
| Parallelism Rules + Agent Dispatch Template (452 words, cited by codegen-agent as canonical) | No canonical home yet - candidate new standards file |
| Triple-stated "load the phase skill" instruction (~150 words) | Phase Conventions section (single statement suffices) |

Regression tests that grep orchestrator content and may pin phrases scheduled for relocation: `test-0000009-rail-tightening.sh`, `test-0000018-req-003`, `test-0000018-req-004`, `test-skill-telemetry.sh` (verify at P1; update relocation-aware, never weaken).
