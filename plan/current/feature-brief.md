---
title: "Feature Brief - Declared product_id and telemetry envelope fix"
summary: "The business case, scope, and product requirements for the feature."
status: "draft"
version: "0.1.0"
---
# Feature Brief - Declared product_id and telemetry envelope fix

**Feature ID:** 0000024-declared-product-id-for-telemetry

> Drafted by the orchestrator from live conversation and diagnostic investigation, for human confirmation.

## Business Goal

Telemetry events currently attribute to a machine-local filesystem path (`git rev-parse --show-toplevel`) instead of a stable declared product identity, so two clones of the same repo on different machines appear as different products. Separately, agent-driven telemetry events (`adr_decision`, `security_finding`, `deviation`, `self_correction`, `spec_gap`, `doc_gap`, `validation_failure`, `retry_limit_exceeded`, `migration_proposal`, `mcp_impact`, `loop_iteration`, `phase_reversal_*`) have been failing 100% of the time since `structured-telemetry-mcp`'s `emit_event` tool renamed its argument from `event` to `envelope` — a fix this repo's own RCA (0000017) recommended and handed off, but never verified landed, and never updated its own call-site instructions for. Both leave telemetry data materially wrong or missing for anyone consuming it.

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| Declared product_id | As a telemetry consumer querying events across multiple projects on one shared backend, I want `product_id` sourced from a durable, human-declared identifier instead of a machine-local filesystem path, so that the same product is attributed consistently regardless of clone location or machine. | must-have | 1 |
| Fix stale envelope parameter | As a telemetry consumer, I want the 12 agent-driven event types the framework specifies to actually reach the backend, so that ADR decisions, security findings, deviations, and other quality signals are queryable instead of silently missing. | must-have | 1 |

Both stories are single-wave — small, same component (`planifest-framework`), no dependency ordering between them beyond both touching `telemetry-standards.md`.

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Owns `planifest-framework/hooks/telemetry/*.mjs`, `planifest-framework/standards/telemetry-standards.md`, and the orchestrator's P0 product.yml read/prompt step (`planifest-framework/skills/planifest-orchestrator/SKILL.md`) |

No new component. `product.yml` (repo root, not under `src/`) gains a required role: canonical home for declared `product_id`, for single- and multi-component projects alike.

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| `product.yml` (`id` field) | planifest-framework | Read by: 3 telemetry hooks, orchestrator P0, any agent-driven `emit_event` call |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| `emit-phase-start.mjs` / `emit-phase-end.mjs` / `context-pressure.mjs` | `structured-telemetry-mcp` `/emit` HTTP endpoint | HTTP POST | Envelope JSON, `product_id` field now sourced from `product.yml` first |
| planifest-orchestrator / phase skills | `structured-telemetry-mcp` `emit_event` MCP tool | MCP tool call | Argument name `envelope` (not `event`) — confirmed live via direct test this session |

## Stack

Inherited — no new stack choice. Markdown skills, Node `.mjs` hooks, no new language/runtime/framework.

| Concern | Decision |
|---------|----------|
| Language | Node.js (hooks), Markdown (skills/standards) |
| Runtime | Node |
| Framework | none |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | bash regression scripts (house convention) |
| IaC | none |
| Cloud | none |
| Compute | local |
| CI | GitHub Actions |
| Build target | local |

## Scope Boundaries

### In Scope
- `getProductId(cwd)` in all 3 telemetry hooks: read `product.yml`'s `id` field first; fall back to current `git rev-parse --show-toplevel` behaviour only if `product.yml` or its `id` field is absent (never hard-block — ADR-005)
- `planifest-orchestrator/SKILL.md` P0 step 3b: if `product.yml` is absent, or present without an `id` field, prompt the human once for a declared product id and write/create `product.yml` with it (creating a minimal `product.yml` for single-component projects if none exists)
- `telemetry-standards.md`: update the Event Envelope section's `product_id` description to reflect the new sourcing order (declared first, path fallback second); update the `emit_event` usage guidance to explicitly show the tool call's top-level argument name is `envelope`, not `event`
- Audit all 8 phase skills' `## Telemetry` sections for any place that names or implies the wrong MCP argument name; fix any found
- Live re-verification: confirm at least one agent-driven event type actually lands end-to-end through the real `emit_event` tool during this feature's own pipeline run (closing 0000017's RCA definition-of-done item 9)

### Out of Scope
- Any change inside the `structured-telemetry-mcp` repo itself — that fix already shipped there; this feature only fixes this repo's stale call-site knowledge of it
- Root Cause B from the 0000017 RCA (missing `loop_iteration`/`phase_reversal_*` schema entries) — out of scope unless discovered still broken during this feature's live re-verification; if so, file a fresh backlog entry rather than fixing here (that fix belongs in the other repo)
- New event types, schema changes, or query/backend changes
- Backfilling historical missing telemetry data

### Deferred
- Nothing identified yet — pending Scope Lock Challenge

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Correctness | 100% of agent-driven `emit_event` calls during this feature's own pipeline run use the correct `envelope` argument and succeed | Build log Telemetry field = `emitted` for every phase, zero `failed-with-recorded-choice` |
| Backward compatibility | Hooks never hard-block regardless of `product.yml` state | Existing ADR-005 behaviour unchanged, verified by regression test |

## Constraints and Assumptions

### Constraints
- Cannot modify `structured-telemetry-mcp` (separate repo, not checked out here)
- Hook-driven emission (`.mjs` scripts) is non-interactive (fire-and-forget subprocess) — cannot itself prompt a human; the prompt must live in the orchestrator's own interactive P0 flow

### Assumptions
- `structured-telemetry-mcp`'s `emit_event` fix (real object schema, `envelope` argument name) is stable/deployed, not a transient state — confirmed via live test this session (`{"ok":true,"id":"f1332a6e-..."}`)
- Every pipeline run has an orchestrator-led P0 phase, so a once-per-run prompt at P0 is sufficient coverage (no separate prompt path needed for hook-only invocations)

## Scenario Paths

**Happy path:** A human runs a pipeline in a project with `product.yml` already declaring `id`. Every hook-driven and agent-driven telemetry event carries that `id` as `product_id`, correctly shaped with the `envelope` argument, and lands in the backend.

**First-run path:** A brand-new single-component project has no `product.yml`. At P0 step 3b, the orchestrator detects this, asks the human for a product id, and creates a minimal `product.yml` containing just `id`. All telemetry for the rest of that run (and future runs) uses the declared id.

**Error / sad path:** `product.yml` exists but is malformed (unparseable YAML) or missing the `id` field specifically. Hooks fall back to the existing git-path behaviour without blocking. The orchestrator's P0 prompt still fires (treats missing `id` the same as missing file) so the gap self-heals on the next run.

**Cross-session continuity:** If P0 is interrupted after the human answers the product-id prompt but before `product.yml` is written, the next session's resume detection re-reads `product.yml`, finds it still absent/incomplete, and re-prompts — no partial-write state to recover, since the write is a single small file operation.

## Acceptance Criteria

- [ ] Given `product.yml` with a declared `id`, all 3 telemetry hooks emit `product_id` equal to that `id`
- [ ] Given no `product.yml` (or one missing `id`), hooks fall back to `git rev-parse --show-toplevel` (or raw cwd) exactly as today — zero regression, zero blocking
- [ ] Given no `product.yml`, the orchestrator's P0 step 3b prompts the human once and creates/updates `product.yml` with the declared id
- [ ] `telemetry-standards.md` correctly documents `emit_event`'s top-level argument as `envelope`
- [ ] At least one agent-driven event (e.g. `adr_decision`) is emitted live during this feature's own P2 and confirmed to land via `query_telemetry`
- [ ] Regression tests exist for the hook fallback behaviour (git-repo cwd, non-git cwd, malformed `product.yml`, missing `id` field) — 4 cases minimum
