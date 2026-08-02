---
title: "Discovery - 0000024-declared-product-id-for-telemetry"
summary: "Raw P0 discovery-pass findings — what the orchestrator knew before coaching began."
---
# Discovery - 0000024-declared-product-id-for-telemetry

> Created at the start of P0, before the first coaching question.
> Raw findings only — decisions belong in `design.md`, the Q&A audit trail in `build-log.md`.

## Header (all modes)

| Field | Value |
|-------|-------|
| Adoption mode detected | `standard-iterative` |
| Detection signal | `plan/_archive/` contains 23 prior feature dirs; `docs/about.md` exists at v0.23.0 |
| Git pre-flight | Branch `main`, confirmed up to date with `origin/main` by human. Branch `feat/0000024-declared-product-id-for-telemetry` created off `main`. |
| Skills inbox | `planifest-framework/skills-inbox/` — empty |

## Mode Findings

### Standard Iterative

- Current version (`docs/about.md`): `0.23.0`, last feature `0000023-framework-pipeline-fixes`
- Prior features (`plan/_archive/`): 23 archived features, most recently `0000023-framework-pipeline-fixes` (02 Aug 2026, req-004 added the `getProductId()` git-path sourcing this feature revises), `0000022-orchestrator-redundancy-removal` (02 Aug 2026), `0000021-framework-context-bloat-audit` (01 Aug 2026), `0000020-setup-refresh-skill` (01 Aug 2026), `0000019-self-description-and-session-hygiene-fixes` (31 Jul 2026), `0000018-telemetry-emission-consistency` (31 Jul 2026), `0000017-ratchet-forgery-detection-and-telemetry-schema-spec` (26 Jul 2026 — filed the RCA this feature closes the loop on), `0000016-pipeline-governance-and-loop-engineering` (11 Jul 2026 — introduced `product.yml` and loop/reversal event types)
- Constraining ADRs (unless superseded):
  - `0000023` ADR-002 — Telemetry guidance centralised: all envelope docs live in `telemetry-standards.md`, skill files reference rather than duplicate. **Supports** story 2's plan to fix the envelope-argument documentation in one place.
  - `0000016` ADR-002 — `product.yml` with `versionPolicy`: root `product.yml` aggregates version across components; **single-component projects explicitly keep component.yml behaviour instead of getting a product.yml.** **Conflicts** with story 1's proposed design (product.yml as canonical `product_id` home for all projects, including single-component). Human confirmed: extend via a new P2 ADR referencing and amending 0000016 ADR-002, rather than storing `product_id` in `component.yml`.
  - `0000018` ADR-001/ADR-002 — unified telemetry signal, mandatory-when-enabled emission, interactive failure recovery. Unaffected by this feature; both stories operate within this existing gate.
  - `0000017` telemetry-mcp-rca-and-fix-spec.md — root-caused the `emit_event` envelope rejection to `structured-telemetry-mcp`'s `z.unknown()` tool schema; handed off fix spec to that repo; left an explicit unclosed follow-up: *"Back in planifest-framework: once deployed, re-run a pipeline phase here with the emit_event tool available and confirm phase_start/phase_end/loop_iteration events actually land... file this as a follow-up verification step at the next P0."* This was never filed or executed until this feature. Live test this session confirms the backend fix (real object schema, argument renamed `event`→`envelope`) is deployed; this repo's own instructions were never updated to match — that gap is story 2.
- Component / data-ownership map (`docs/`): `planifest-framework` component owns `hooks/telemetry/*.mjs`, `standards/telemetry-standards.md`, and the orchestrator's own P0 logic. No other component touched by either story.
