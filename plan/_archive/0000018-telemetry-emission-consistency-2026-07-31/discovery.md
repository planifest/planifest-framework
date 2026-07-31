---
title: "Discovery - 0000018-telemetry-emission-consistency"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000018-telemetry-emission-consistency

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.
> Fresh each pipeline run: filed to the archive at P7, recreated at the next P0.
> A section whose signal could not be read states that plainly — coaching proceeds on the rest.

> **Note:** written retroactively partway through P0 — this pipeline run began coaching before req-006's discovery-pass step was applied to itself. Backfilled here from the same signals the step would have gathered at P0 start; no coaching content was lost since build-log.md already captured the full Q&A incrementally regardless.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `standard-iterative` |
| Detection signal | `plan/_archive/` contains 17+ prior features; `docs/about.md` exists at version 0.17.0 |
| Git pre-flight | branch `main` at session start, clean, up to date with `origin/main` (confirmed after PR #41 merge); feature branch `feat/0000018-telemetry-emission-consistency` created from `main` at commit `d6e8d23` |
| Skills inbox | `planifest-framework/skills-inbox/` empty |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.17.0`, last feature `0000017-ratchet-forgery-detection-and-telemetry-schema-spec`, updated 26 Jul 2026
- Prior features (`plan/_archive/`, most recent): 0000013 (codegen component version bump), 0000014 (adoption mode selection), 0000015 (pipeline session cleanup), 0000016 (pipeline governance and loop engineering), 0000017 (ratchet forgery detection and telemetry schema spec), plus `backlog-triage-2026-07-11` (Change Pipeline run)
- Constraining ADRs (unless superseded):
  - ADR-005 (0000003, "Exit-zero failure mode") — hooks never exit non-zero on unexpected errors, session must never be blocked by a hook bug. Directly constrains this feature's hook failure-marker mechanism: it must record failure, never block or throw.
  - ADR-002 (0000007, "Telemetry guidance centralised") — all telemetry envelope docs live in `telemetry-standards.md`; skill files reference it rather than duplicating. Constrains how the 8 phase skills' Telemetry sections should be rewritten: point at the standard, don't re-document the envelope in each skill.
  - 0000017 ADR-002 (Cross-Platform Hook Runtime Unification) — established the `.mjs`-only, Node-required convention for context-mode hooks; the telemetry hooks (`emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs`) are already `.mjs`, consistent with this.
- Component / data-ownership map (`docs/component-registry.md`): `context-mode-hooks` (block-*.mjs hook scripts), `setup-hook-integration` (setup.sh/ps1, skill-sync, hook adapters — installs telemetry hooks among others), `planifest-framework` (core skills/standards, v0.17.0). This feature's changes land primarily in `planifest-framework` (skills, `telemetry-standards.md`, `hooks/telemetry/*.mjs`) and `setup-hook-integration`'s installer logic (`setup.sh`/`setup.ps1`), not in `context-mode-hooks` (unrelated hook family).
