---
title: "Discovery - 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes

> Created at the start of P0, before the first coaching question, in every adoption mode.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.
> Unreadable signal: say so; coaching proceeds.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `Standard Iterative` |
| Detection signal | `plan/_archive/` contains 24 prior feature directories; `docs/about.md` exists with version `0.24.0` |
| Git pre-flight | Branch `feat/0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes`, created from `main` confirmed up to date via GUTD sync earlier this session (fast-forwarded to `b9a0257`, merging feature 0000024) |
| Skills inbox | `planifest-framework/skills-inbox/` — empty, no pending capability skills |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.24.0`; cross-checked against `product.yml` (`versionPolicy: max-component-version`, also `0.24.0`) — consistent, not an external-anchor project
- Prior features (`plan/_archive/`): 24 features, `0000001-context-mode-enforcement-hooks` through `0000024-declared-product-id-for-telemetry`; this run's stories originate as backlog items filed by features `0000016` (0000029), `0000023` (0000033, 0000034, 0000035, 0000036, 0000037, 0000038), and `0000024` (0000039), plus two filed by a downstream adopter repo ("telemetry-mcp" product) directly against this framework's backlog (0000040, 0000041)
- Constraining ADRs (unless superseded):
  - `0000017-ADR-003` (Scope Lock Suggested Answers via On-Demand Subagent) — directly reversed by the merged 0000029+0000040 story; will need a superseding ADR in P2
  - `0000014-ADR-008` (One-Question-at-a-Time as Framework-Wide Instruction) — the batch-presentation half of the merged 0000029+0000040 story touches this convention for the Scope Lock Challenge specifically; needs scoping in P2 so it doesn't read as a silent framework-wide reversal
  - `0000012-ADR-003` (Ship-agent orchestrates P7-P9) — relevant context for both ship-agent stories (0000039, 0000033)
  - `0000006-ADR-003` (Parallelism as skill instructions, not code) — relevant context for the subagent-parallelism story (0000036)
  - `0000016-ADR-001` (Backlog Folder Instead of Editable Post-Archive Lifecycle) — relevant context for the backlog-unification story (0000038)
- Component / data-ownership map (`docs/component-registry.md`): single relevant component for this run — `planifest-framework` (core standards, skills, hooks, setup scripts). No data ownership concerns; this run changes skill/process behavior, not application data.
