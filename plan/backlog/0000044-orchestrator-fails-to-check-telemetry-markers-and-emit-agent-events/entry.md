---
title: "Backlog Entry: 0000044 - Orchestrator fails to check telemetry failure markers promptly and fails to make agent-driven emit_event calls"
summary: "0000018-ADR-002's failure-detection protocol and each phase skill's agent-driven emit_event requirements (adr_decision, spec_gap, etc.) are pure prose instructions with no deterministic backstop — during feature 0000025's own P0-P2, the orchestrator marked build-log Telemetry fields 'emitted' without verifying, missed an unacknowledged failure marker at a phase boundary, and never actually called emit_event for any agent-driven event until the human caught it."
status: "open"
---
# Backlog Entry: 0000044 - Orchestrator fails to check telemetry failure markers promptly and fails to make agent-driven emit_event calls

**Source feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source phase:** P2

**Date filed:** 2026-08-03

---

## Problem

Two related self-audit findings from this feature's own P0-P2 run, both instances of the same root cause: telemetry compliance is currently enforced by prose instruction alone (in `planifest-orchestrator/SKILL.md` and each phase skill's own `## Telemetry` section), with no deterministic backstop, so it's easy for an agent to silently skip it under normal task pressure:

1. **Failure-marker check skipped at a phase boundary.** `0000018-ADR-002` requires checking `plan/.telemetry-failures/` "at the start of every phase (P0 through P9), before any phase work begins." The orchestrator checked once at P0 start (directory was empty) and then did not re-check at the P1→P2 boundary despite a `context-pressure` failure marker existing since 01:08:52 UTC — it sat unacknowledged through the rest of P1 and into P2 until the human asked "are you seeing failures?" directly.
2. **Agent-driven `emit_event` calls never made.** `planifest-spec-agent`'s and `planifest-adr-agent`'s own `## Telemetry` sections specify events (`spec_gap`, `adr_decision`) that the *agent itself* should call `emit_event` for. Across P0, P1, and P2 of this run, the orchestrator recorded `Telemetry: emitted` in `plan/current/build-log.md` for each phase without ever actually invoking the tool — an unverified assumption that hook-driven coverage was sufficient, which was also wrong (see backlog 0000043). The gap was only caught and backfilled after the human raised it.

## Suggested Action

Design a deterministic backstop rather than relying on the orchestrator remembering, consistent with `0000016-ADR-007`'s "Deterministic Caps, Budget, and Ratchet Enforcement" precedent (caps/budgets/ratchets are enforced by hooks + control flow, "never skill prose alone" — the same principle should extend to telemetry compliance). Candidate approaches to evaluate at pickup: a `UserPromptSubmit` or phase-transition hook that checks `plan/.telemetry-failures/` automatically and injects a visible reminder/block into context if an unacknowledged marker exists (removing reliance on the orchestrator's own memory); and/or a lightweight lint/check step the orchestrator runs at each phase gate that fails visibly if a phase's `Telemetry` build-log field was set without a corresponding tool-call record. Exact mechanism is a design decision for pickup, not decided here.

## Why Deferred

Out of scope for 0000025 (that feature's 7 stories are specific, already-scoped fixes; this is a broader telemetry-compliance-enforcement gap spanning the orchestrator's own P0-P9 conduct, not a single skill file edit). Discovered live, self-reported by the orchestrator once the human asked about it directly — the human wants this picked up as the next feature after 0000025.
