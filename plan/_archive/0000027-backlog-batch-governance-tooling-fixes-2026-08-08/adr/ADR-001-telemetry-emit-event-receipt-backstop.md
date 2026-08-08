---
title: "ADR 001: Telemetry emit_event receipt backstop"
summary: "Extends the existing check-telemetry-failures.mjs hook family with a PostToolUse receipt writer for emit_event, closing the remaining half of backlog 0000044 (agent-driven emit_event calls verified, not just claimed)."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Telemetry emit_event receipt backstop

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

Backlog `0000044` (this feature's req-004) reported two related findings from feature `0000025`'s own P0-P2 self-audit: (1) the orchestrator missed an unacknowledged `plan/.telemetry-failures/` marker at a phase boundary, and (2) agent-driven `emit_event` calls (`spec_gap`, `adr_decision`, etc., specified in each phase skill's own `## Telemetry` section) were never actually invoked despite build-log recording `Telemetry: emitted`. Feature `0000026` (folded in from the same backlog entry) already shipped `check-telemetry-failures.mjs`, a read-only `UserPromptSubmit` hook that surfaces an `additionalContext` reminder when an unacknowledged failure marker exists — this closes finding (1). Finding (2) remains open: nothing today verifies that a phase's claimed `emitted` status corresponds to an actual tool call having occurred, consistent with `0000016-ADR-007`'s "deterministic caps/budgets/ratchets, never skill prose alone" precedent.

## Decision

Add a `PostToolUse` hook matched on the `emit_event` MCP tool call (`mcp__structured-telemetry-mcp__emit_event`, per the tool's actual invocation name) that, on a successful call, writes a durable local receipt file under `plan/.telemetry-receipts/{phase}-{event_type}-{ISO-8601-timestamp}.marker` containing the event envelope's `phase_name`/`event_type` fields. Extend `check-telemetry-failures.mjs` (or add a narrowly-scoped sibling hook in the same family, implementer's choice at P3 based on what keeps the diff smallest) to cross-reference, at each `UserPromptSubmit`, the current phase's expected agent-driven event types (read from the invoking phase skill's own `## Telemetry` section, or a small static table derived from it) against receipts present for that phase; inject an `additionalContext` reminder if an expected event type has no corresponding receipt once the phase has otherwise completed its build-log entry. This is read-only and advisory like its sibling, per the existing hook family's design (never blocks, never decides, only surfaces).

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| A new standalone verification hook unrelated to `check-telemetry-failures.mjs` | Clean separation of concerns | Duplicates the existing `UserPromptSubmit` reminder-injection plumbing; two near-identical hooks to maintain | Extending the existing hook reuses proven plumbing and keeps the telemetry-backstop surface in one family |
| Rely on P8 build assessment to audit `emit_event` compliance after the fact | No new hook code | Backward-looking only; a whole pipeline run could complete non-compliant before anyone notices, same failure mode this ADR exists to close | Contradicts the "deterministic, not after-the-fact" requirement in req-004 |
| Require the orchestrator to self-report emit_event calls in build-log only (status quo, strengthened by prose) | No implementation cost | This is exactly the mechanism that already failed once (0000025's own self-audit) — prose reminders don't survive task pressure | Rejected per `0000016-ADR-007`'s explicit precedent against prose-only enforcement |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | New `PostToolUse` receipt-writing hook; `check-telemetry-failures.mjs` (or sibling) gains a second check mode; `.claude/settings.json` hook registration gains one entry |
| setup-hook-integration | `setup.sh`/`setup.ps1` must install and register the new receipt-writing hook alongside the existing telemetry hooks, gated by the same unified telemetry signal |

## Consequences

**Positive:**
- Closes the second half of backlog `0000044` without introducing a new hook family — the orchestrator's `Telemetry: emitted` claim becomes independently checkable rather than self-attested.

**Negative:**
- One more hook entry to install, register, and keep in parity across `setup.sh`/`setup.ps1` — a small addition to the surface `req-001` is already touching in this same feature.

**Risks:**
- If the receipt-writing hook itself fails silently (e.g. the MCP tool name changes), the cross-reference check would have nothing to compare against and could produce false-negative reminders (looks compliant when it isn't) — mitigate by having the receipt hook's own failure route through the existing `plan/.telemetry-failures/` marker mechanism, consistent with how other telemetry hooks already report their own failures.

## Related ADRs

- 0000016-ADR-007 - depends-on (deterministic enforcement precedent)
- 0000018-ADR-002 - extends (telemetry failure detection and interactive recovery)

## Supersedes

- None

## Superseded By

- None
