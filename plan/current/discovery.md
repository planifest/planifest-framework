---
title: "Discovery - 0000020-setup-refresh-skill"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000020-setup-refresh-skill

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.
> Fresh each pipeline run: filed to the archive at P7, recreated at the next P0.
> A section whose signal could not be read states that plainly — coaching proceeds on the rest.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `Standard Iterative` |
| Detection signal | `plan/_archive/` contains 19 prior feature dirs + `docs/about.md` exists at v0.19.0 |
| Git pre-flight | branch was `main` at session start, human confirmed up to date, switched to `feat/0000020-setup-refresh-skill` |
| Skills inbox | empty — no pending `SKILL.md` files in `planifest-framework/skills-inbox/` |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.19.0`, last feature `0000019-self-description-and-session-hygiene-fixes`
- Prior features (`plan/_archive/`): 19 features from `0000001-context-mode-enforcement-hooks` (2026-04-xx) through `0000019-self-description-and-session-hygiene-fixes` (2026-07-31), plus one `backlog-triage-2026-07-11` archive dir. Most relevant to this feature: `0000011-setup-parity-and-consistency-2026-05-17` (setup.sh/.ps1 parity work) and `0000007-agent-optimisation-2026-05-04` (ADR-004 setup manifest for managed directories).
- Constraining ADRs (unless superseded):
  - `0000011` ADR-001 hook deny response format, ADR-002 workspace hook config write strategy, ADR-003 hook adapter architecture — constrain how setup.sh writes hook wiring into `.claude/settings.json` and tool-specific equivalents.
  - `0000007` ADR-004 setup manifest for managed directories — constrains what setup.sh is allowed to delete/overwrite vs. leave alone.
  - `0000018` ADR-001 (unified telemetry signal) — `--structured-telemetry-mcp` is the single gating condition for telemetry; relevant since the refresh skill must detect this flag.
- Component / data-ownership map (`docs/component-registry.md`): `setup-hook-integration` (setup.sh/ps1, skill-sync, hook adapters — installs/configures enforcement, telemetry, context-mode hooks) is the component that owns setup.sh/setup.ps1. `planifest-framework` (component-pack) owns the skills library and templates under `planifest-framework/`. This feature's changes (new skill under `planifest-framework/skills/`, possible marker-file convention, no changes to setup.sh's own logic anticipated) map primarily to `planifest-framework`, with `setup-hook-integration` as a read-only dependency (the new skill re-invokes `setup.sh`/`setup.ps1` but does not modify their internals per the backlog entry's suggested action).

## Backlog Source

Backlog entry `0000013-setup-refresh-skill-preserving-settings` pulled in whole — see `plan/current/feature-brief.md` for the folded content. Original problem statement, suggested action, and deferral rationale preserved verbatim in the brief.
