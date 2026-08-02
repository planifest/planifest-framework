# Changelog — 0000024-declared-product-id-for-telemetry — 03 Aug 2026

**Feature:** Declared product_id and telemetry envelope fix
**Pipeline run:** P0–P9 complete, no phases skipped
**PR:** pending — updated after PR is raised in Step 10

## What Was Built

Telemetry's `product_id` no longer derives from a machine-local filesystem path (`git rev-parse --show-toplevel`). It is now sourced exclusively from `product.yml`'s `id` field — a durable, human-declared identity that the orchestrator's P0 now hard-stops to collect if missing, for single-component projects as well as multi-component ones. Separately, this feature root-caused and fixed a silent, total failure of agent-driven telemetry: `structured-telemetry-mcp`'s `emit_event` MCP tool argument was renamed from `event` to `envelope` at some point after this repo's own RCA (feature 0000017) diagnosed a related backend defect and handed off a fix — that RCA left an explicit, never-executed follow-up ("re-run a pipeline phase here... confirm events actually land") which this feature finally performed, live, mid-run.

## Artifacts Produced

`feature-brief.md`, `design.md`, `discovery.md`, `build-log.md`, `requirements/req-001-declared-product-id.md`, `requirements/req-002-fix-envelope-parameter.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`, `execution-plan.md`, `operational-model.md`, `slo-definitions.md`, `cost-model.md`, `adr/ADR-001-product-yml-for-single-component-projects.md`, `security-report.md`, `recommendations.md`. Code: `planifest-framework/hooks/telemetry/{emit-phase-start,emit-phase-end,context-pressure}.mjs` (rewritten), `planifest-framework/skills/planifest-orchestrator/SKILL.md` (P0 step 3b extended), `planifest-framework/standards/telemetry-standards.md` (envelope argument + product_id sourcing docs fixed), `planifest-framework/tests/test-0000024-req-001-declared-product-id.sh` (new, 42 assertions).

## Decisions

- **ADR-001:** `product.yml`'s `id` field becomes the canonical declared `product_id` for telemetry across all projects, including single-component ones — extends (does not supersede) 0000016 ADR-002, whose versioning-only decision remains fully in force.

## Skipped Phases

None.
