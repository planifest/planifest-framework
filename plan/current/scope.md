---
title: "Scope - telemetry-hardening-and-enforcement-fixes"
summary: "Defines explicit boundaries of what is in scope and out of scope."
status: "active"
version: "0.1.0"
---
# Scope - telemetry-hardening-and-enforcement-fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Wave:** single wave (not waved)
**Version:** 0.28.0

## In Scope

- Bounded retry on network-level emission failures only, across all five telemetry hooks: `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `emit-event-receipt.mjs`, `resolve-phase.mjs`. Backlog `0000063` named three; discovery found five. Retry never fires on an HTTP error status.
- Extraction of the duplicated emit-and-record logic, `readProductId()` (`0000054`), and the phase-enum maps (`0000057`) into shared modules, created before any caller is rewired.
- A stderr fallback line when a marker write itself fails, so a failing marker write is never fully silent.
- A `.gitignore` entry for `plan/.telemetry-receipts/`, matching the existing `plan/.telemetry-failures/` treatment.
- Refresh of this repo's stale install so the phase telemetry hooks (`emit-phase-start.mjs`, `emit-phase-end.mjs` via `resolve-phase.mjs`) are actually registered in `.claude/settings.json`.
- Live verification of `resolve-phase.mjs` against a real hook firing, not direct script invocation (`0000058`), confirming or correcting its `PreToolUse(Skill)` matcher and `tool_input.skill` field assumption.
- Verification that the telemetry schema carries `loop_iteration` and `phase_reversal_*` fields, or recording the gap if it does not (`0000053`).
- A deterministic em dash check at write time over Planifest artifacts, following the `commit-msg` hook precedent, plus a bounded one-off cleanup of existing live artifacts.
- Closure of backlog `0000042`, `0000051`, and `0000052`, all of which resolve without new code in this feature.

## Out of Scope

- Backlog `0000020`, structural router decomposition of the orchestrator skill. Ranked highest on value at P0 and deliberately excluded by the human on the loop as warranting a dedicated run with a populated regression pack.
- Backlog `0000060`, `0000061`, `0000062`, reviewed at P0 and judged not valuable enough for this run.
- Backlog `0000064`, Playwright MCP as a setup flag, filed during this P0.
- New wiring code for the phase hooks. `setup.sh:626`'s `merge_telemetry_hook_settings()` already does this, shipped in `0000027`. This repo's `.claude/` install is simply stale, and `.claude/` is gitignored, so refreshing it is local machine state, not a repo change.
- Any change to `block-bash.mjs`. The loopback fix for backlog `0000042`'s false-positive class already shipped in `0000026` (`7f28593`); this feature only closes the backlog entry, it does not touch the hook again.
- Any queue, buffer, or local fallback for undelivered telemetry. A failure is still dropped and still recorded via the durable marker; only the definition of failure narrows.
- Retry on HTTP error status. A 4xx or 5xx means a listener answered and rejected the event, which is a real failure, not a listener gap.
- Em dash cleanup of `plan/_archive/` and `plan/changelog/`. Those are historical record; rewriting shipped artifacts to satisfy a rule introduced afterwards would falsify the audit trail.
- Backlog `0000022` (token accounting) and `0000056` (phase-completion signalling). Both become actionable only once the phase hooks emit, and are candidates for the next run.

## Deferred

- The broader AI writing-tells list from `0000026`, beyond the em dash. Needs its own decision on which artifacts are in scope and whether enforcement is a hook or instruction-only. Nothing in this feature is blocked by it; the em dash check ships standalone.
- Whether `0000042`'s loopback approach should generalise to `block-grep.mjs` and `block-webfetch.mjs`. To be assessed at P1 once this feature's false-positive class is characterised; the other two hooks may not share the pattern. Nothing in this feature is blocked by it, since `0000042`'s own fix already shipped in `0000026`.
