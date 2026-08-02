---
title: "Requirement: req-004 - Telemetry Product ID Emission"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-004 - Telemetry Product ID Emission

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Source:** US-004
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As anyone consuming telemetry data across multiple projects sharing one backend — a human via the log-viewer UI, an API caller, or an agent querying via MCP tools — I want every event the framework emits to carry `product_id`, so that events attribute to the right repo regardless of how they're consumed, instead of showing "unknown".

## Functional Requirements

- In `planifest-framework/hooks/telemetry/emit-phase-start.mjs`, add a `getProductId(cwd)` helper (same shape as the file's existing duplicated-per-file helper pattern, e.g. `recordTelemetryFailure`) that resolves the emitting repo's git root via `git rev-parse --show-toplevel`, falling back to the raw `cwd` on any failure. Set `product_id: getProductId(cwd),` on the `event` object literal, using the `cwd` already resolved at line 159 (`cwd = input?.cwd ?? process.cwd();`). The helper needs `execFileSync` from `node:child_process`, added to the import block (currently lines 47–50).
- In `planifest-framework/hooks/telemetry/emit-phase-end.mjs`, add the same `getProductId(cwd)` helper and set `product_id: getProductId(cwd),` on the `event` object literal, using the `cwd` already resolved at line 145 (`cwd = input?.cwd ?? process.cwd();`). The helper needs `execFileSync` from `node:child_process`, added to the import block (currently lines 44–46).
- In `planifest-framework/hooks/telemetry/context-pressure.mjs`, add the same `getProductId(cwd)` helper and set `product_id: getProductId(cwd),` on the `event` object literal, using the `cwd` already resolved at line 140 (`cwd = input?.cwd ?? process.cwd();`). The helper needs `execFileSync` from `node:child_process`, added to the import block (currently lines 48–49).
- The `getProductId` helper implementation, identical across all three files:
  ```js
  import { execFileSync } from "node:child_process";

  function getProductId(cwd) {
    try {
      return execFileSync("git", ["rev-parse", "--show-toplevel"], {
        cwd,
        encoding: "utf-8",
        stdio: ["ignore", "pipe", "ignore"],
      }).trim();
    } catch {
      return cwd;
    }
  }
  ```
- The helper MUST be duplicated per file, not shared via a common import — this matches these three files' existing pattern of duplicating small helpers (e.g. `recordTelemetryFailure`, `readStdin`) rather than importing from a shared module.
- In `planifest-framework/standards/telemetry-standards.md`, the "Event Envelope" section's JSON template (lines 108–121) MUST gain one field: `"product_id": "<git repo root, or cwd if not a git repo>",`. This is the single canonical envelope every phase skill's `## Telemetry` section is documented as referencing rather than copying (line 123: "the full envelope above always wraps it").
- The same "Event Envelope" section MUST document that agent-driven inline `emit_event` calls (made in-conversation by phase skills via a Bash/shell-out call, not via the `.mjs` hooks) derive `product_id` the same way — `git rev-parse --show-toplevel` from the agent's own cwd, falling back to cwd on failure. This is a usage-instruction addition to the canonical template, not a separate code change: none of the 8 skill files that reference `emit_event` (`planifest-orchestrator`, `planifest-spec-agent`, `planifest-adr-agent`, `planifest-codegen-agent`, `planifest-validate-agent`, `planifest-security-agent`, `planifest-docs-agent`, `planifest-change-agent`) hardcode a literal copy of the envelope — confirmed via `grep -rl '"schema_version"' planifest-framework/skills/` returning no matches — so there is no separate per-skill edit required for this requirement.
- Regression tests MUST be added under `planifest-framework/tests/regression/` (bash, matching the house style of the existing hook regression tests, e.g. `test-0000018-req-002-hook-failure-marker.sh`), one per hook, covering both a git-repo cwd and a non-git-repo cwd (e.g. a fresh `mktemp -d` outside any repo) and asserting the POSTed event body contains the expected `product_id`.

## Acceptance Criteria
- [ ] Given a cwd inside a git repo, each of the 3 hooks' (`emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs`) emitted event has `product_id` equal to that repo's `git rev-parse --show-toplevel` output
- [ ] Given a cwd outside any git repo, `product_id` equals the raw cwd
- [ ] A missing/failing `git` binary does not throw or block emission — `getProductId` falls back to `cwd` and the hook's existing exit-zero/never-block behaviour (ADR-005) is unchanged
- [ ] No added latency beyond the existing ~3s fetch-abort budget — `git rev-parse --show-toplevel` is local, synchronous, sub-millisecond, and runs before the fetch
- [ ] `telemetry-standards.md`'s Event Envelope section includes `product_id` in the canonical JSON template, plus usage instructions for agent-driven inline `emit_event` calls deriving it the same way
- [ ] Audit of the 8 skill files' `## Telemetry` sections confirms none hardcode a stale envelope copy missing the field (confirmed clean at spec time; re-verify at implementation time in case any drifted)
- [ ] Regression tests exist and pass under `planifest-framework/tests/regression/` for both the git-repo and non-git-repo cwd cases, for all 3 hooks

## Dependencies
- None — self-contained within `planifest-framework/hooks/telemetry/` and `planifest-framework/standards/telemetry-standards.md`.
- No dependency on `structured-telemetry-mcp`: that product's schema, DB/query layer, and UI already read/store/filter on `product_id` (shipped in that product's own feature 0000015) and require no change here. No backfill of historical rows (per that product's ADR-017) — existing NULL/absent rows remain permanently "unknown".

## Background

`structured-telemetry-mcp`'s telemetry-event schema already has `product_id` as an optional, defined, top-level envelope field. Every consumption path on that side (DB, query, UI) already handles it. What's missing is purely additive wiring on the framework side: three hook scripts don't populate a field that already has a home, and the canonical envelope template they're documented against doesn't mention it either.

This requirement is scoped to that wiring only. It does not touch `structured-telemetry-mcp` in any way, does not change any schema, and does not introduce new telemetry event types or backfill historical data.
