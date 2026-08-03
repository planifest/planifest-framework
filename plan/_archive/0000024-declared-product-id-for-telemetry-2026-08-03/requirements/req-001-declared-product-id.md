---
title: "Requirement: req-001 - Declared product_id for telemetry"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-001 - Declared product_id for telemetry

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000024-declared-product-id-for-telemetry
**Source:** US-001
**Priority:** must-have

## User Story

As a telemetry consumer querying events across multiple projects on one shared backend, I want `product_id` sourced from a durable, human-declared identifier instead of a machine-local filesystem path, so that the same product is attributed consistently regardless of clone location or machine.

## Functional Requirements

- Delete the `getProductId(cwd)` function and its `execFileSync("git", ["rev-parse", "--show-toplevel"], ...)` git-path-derivation logic entirely from `planifest-framework/hooks/telemetry/emit-phase-start.mjs` (lines 94-104), `planifest-framework/hooks/telemetry/emit-phase-end.mjs` (lines 80-90), and `planifest-framework/hooks/telemetry/context-pressure.mjs` (lines 78-88). No caller in any of the three files may retain a reference to `getProductId`.
- Replace each deleted call site (`product_id: getProductId(cwd)` in the `event` object literal of each of the 3 hooks) with a read of `product.yml`'s top-level `id` field, resolved relative to the hook's `cwd` (repo root convention per `product.yml`'s existing location).
- `product.yml` is the sole source of `product_id` in all 3 hooks. No hook may emit a filesystem path, `cwd`, or any other fallback value as `product_id` under any condition.
- If `product.yml` is absent at `cwd`, cannot be parsed as valid YAML, or parses without an `id` field (empty, null, or missing key), each hook must treat this as an emission failure: the error is caught by the hook's existing top-level `try`/`catch`, and routed through that hook's existing `recordTelemetryFailure(hookName, err, context)` function — no new marker format, no new failure-handling code path is introduced.
- No hook may hard-block the session under any `product.yml` condition (absent, malformed, missing `id`, or present and valid): all 3 hooks must retain their unconditional `process.exit(0)`-on-success / silent-catch-on-failure behaviour, per ADR-005 (fire-and-forget, non-blocking telemetry hooks).
- Extend `planifest-orchestrator/SKILL.md` Phase 0 Start Actions step 3b (currently: reads `docs/about.md` and, if present, `product.yml` for version-bump purposes only) so that, before that step completes, the orchestrator also checks whether `product.yml` exists and contains a non-empty `id` field. If `product.yml` is absent, or present without an `id` field, the orchestrator hard-stops step 3b and asks the human on the loop to declare a product id before proceeding to the rest of Phase 0.
- Once the human supplies a product id, the orchestrator creates `product.yml` if it does not exist (a minimal file containing only `id`, consistent with 0000016 ADR-002's "single-component projects keep component.yml behaviour" rule extended to cover this new `id`-declaration case) or adds/updates the `id` field on the existing `product.yml`, preserving all other existing fields (e.g. `name`, `version`, `versionPolicy`, `components`) unchanged.
- This orchestrator-side hard-stop is the only interactive prompt path for resolving a missing/malformed declared product id; it does not alter the 3 hooks' own non-interactive, never-block behaviour described above.

## Acceptance Criteria

- [ ] `grep -rn "getProductId" planifest-framework/hooks/telemetry/` returns zero matches across all 3 hook files
- [ ] `grep -rn "rev-parse.*show-toplevel" planifest-framework/hooks/telemetry/` returns zero matches across all 3 hook files
- [ ] Given a `product.yml` at `cwd` with a declared `id`, each of the 3 hooks emits `product_id` in its POSTed event body equal to that `id`
- [ ] Given no `product.yml` at `cwd`, each of the 3 hooks writes/updates a marker file under `plan/.telemetry-failures/` via `recordTelemetryFailure()`, exits 0, and never emits a path-shaped `product_id`
- [ ] Given a `product.yml` at `cwd` containing unparseable YAML, each of the 3 hooks writes/updates a marker file via `recordTelemetryFailure()`, exits 0, and never emits a path-shaped `product_id`
- [ ] Given a `product.yml` at `cwd` that parses but has no `id` field, each of the 3 hooks writes/updates a marker file via `recordTelemetryFailure()`, exits 0, and never emits a path-shaped `product_id`
- [ ] `planifest-orchestrator/SKILL.md` Phase 0 Start Actions step 3b hard-stops and prompts the human when `product.yml` is absent or missing `id`, before the rest of Phase 0 proceeds
- [ ] After the human answers the step 3b prompt, `product.yml` exists with the declared `id` set, and any pre-existing fields on `product.yml` (e.g. `version`, `components`) are unchanged
- [ ] Regression test coverage exists for at minimum: declared id present (success, `product_id` equals declared id), `product.yml` absent (failure marker written, hook exits 0), malformed YAML (failure marker written, hook exits 0), `id` field missing (failure marker written, hook exits 0) — none of these cases asserts a path-shaped `product_id` value, superseding the now-obsolete git-path assertions in `planifest-framework/tests/test-0000023-req-004-telemetry-product-id-emission.sh`

## Dependencies

- New P2 ADR extending 0000016 ADR-002 (`plan/_archive/0000016-.../adr/ADR-002-product-yml-version-policy.md`) to cover `product.yml`'s new required role as the canonical source of declared `product_id`, including the "create a minimal `product.yml` for single-component projects" extension of ADR-002's existing single-component behaviour rule — filed separately by the ADR agent, not implemented by this requirement
- Each hook's existing `recordTelemetryFailure()` function and `plan/.telemetry-failures/` marker mechanism (req-002, ADR-002 from 0000018) — reused as-is, not modified by this requirement
- ADR-005 (non-blocking, fire-and-forget telemetry hooks) — behaviour preserved unchanged by this requirement
