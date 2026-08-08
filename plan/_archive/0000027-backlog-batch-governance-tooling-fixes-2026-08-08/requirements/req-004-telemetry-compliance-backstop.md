---
title: "Requirement: req-004 - Telemetry Compliance Backstop"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-004 - Telemetry Compliance Backstop

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-004 (0000044)
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As the orchestrator, I want a deterministic backstop that checks `plan/.telemetry-failures/` at every phase boundary and verifies agent-driven `emit_event` calls actually happened, so that telemetry compliance doesn't depend solely on prose instruction and memory.

## Functional Requirements

> The exact mechanism (hook, lint/gate-check step, or both) is explicitly undecided per the confirmed design (`plan/current/design.md` Assumptions/Risks) and is deliberately **not** chosen here. These requirements state WHAT must be true; a P2 ADR resolves HOW (see Dependencies).

- A deterministic check — not orchestrator memory or skill prose alone — MUST verify that `plan/.telemetry-failures/` is checked for an unacknowledged failure marker at every phase boundary (before/after each P0-P9 phase transition) while the unified telemetry signal is active.
- An unacknowledged telemetry-failure marker MUST NOT be able to silently persist past one phase boundary without being surfaced to the human via the existing block-or-proceed question defined in `0000018-ADR-002` ("Telemetry emission failed: {error}. Block until resolved, or proceed without telemetry for the rest of this run?").
- A deterministic check MUST verify that each agent-driven `emit_event` call specified per phase skill's own Telemetry section (`adr_decision`, `security_finding`, `self_correction`, `deviation`, `spec_gap`, `doc_gap`, `validation_failure`, `retry_limit_exceeded`) actually occurred for a phase that ran — a build-log `Telemetry` field marked "emitted" with no corresponding tool-call record MUST be flagged, matching the exact failure mode that motivated this backlog item (feature `0000025`'s P0-P2 run, where the orchestrator marked fields "emitted" without verifying and never called `emit_event` until the human caught it).
- The check's failure or violation MUST be visible to the human at the phase gate where it is detected — not swallowed, not silently auto-corrected, and not deferred to a later summary.
- The check MUST read `plan/.telemetry-failures/`'s existing marker format as already fixed by `0000018-ADR-002` (a durable marker per unresolved root cause, recording hook name + error identity, itself written best-effort by the emitting hook) — this requirement does not introduce a new or incompatible marker format.
- This backstop extends the same principle already established for caps/budgets/ratchets in `0000016-ADR-007` ("Deterministic Caps, Budget, and Ratchet Enforcement" — enforced by hooks and control flow, never skill prose alone); the chosen mechanism must satisfy that same standard for telemetry compliance specifically.

## Acceptance Criteria

- [ ] An unacknowledged telemetry-failure marker in `plan/.telemetry-failures/` cannot silently persist past one phase boundary without being surfaced to the human via the block-or-proceed question
- [ ] A deterministic check (not orchestrator memory or skill prose alone) confirms `plan/.telemetry-failures/` was checked at each phase boundary where the unified telemetry signal is active
- [ ] A deterministic check confirms that each agent-driven `emit_event` call specified in a phase skill's Telemetry section actually occurred when that phase ran, and visibly flags a mismatch (e.g. build-log marked "emitted" with no corresponding call)
- [ ] The check reads `plan/.telemetry-failures/`'s existing marker format (per `0000018-ADR-002`) without introducing an incompatible new format
- [ ] The check's failure is surfaced to the human at the phase gate where detected, not merely logged or silently corrected
- [ ] The chosen mechanism (once resolved by the P2 ADR referenced below) is documented as satisfying the `0000016-ADR-007` "never skill prose alone" standard for telemetry specifically

## Dependencies

- **Blocking: a P2 ADR must resolve the backstop mechanism** (hook vs. lint/gate-check step vs. both) before this requirement can be fully implemented at P3. This requirement is written at the level of WHAT must hold precisely because the mechanism choice is out of scope for P1 per the confirmed design's Assumptions ("0000044's exact mechanism is explicitly undecided... mitigated by resolving both as ADRs before codegen") and Risks ("0000044's backstop mechanism... is explicitly undecided — likelihood: medium, impact: medium").
- `planifest-framework/standards/telemetry-standards.md` — Failure Detection and Interactive Recovery (`0000018`, `ADR-002`), phase_start/phase_end Ownership, Event Type Reference.
- `plan/.telemetry-failures/` — existing marker format and directory this backstop must read, fixed by `0000018-ADR-002`.
- `0000016-ADR-007` (deterministic caps/budget/ratchet enforcement) — the precedent this backstop extends to telemetry.
- Each phase skill's own Telemetry section (`planifest-spec-agent`, `planifest-codegen-agent`, `planifest-validate-agent`, `planifest-security-agent`, `planifest-docs-agent`, `planifest-adr-agent`, `planifest-ship-agent`) — defines which agent-driven `emit_event` calls apply per phase and is what the check verifies against.
- Suggested (non-blocking) sequencing per `feature-brief.md`: this requirement logically follows `req-001` (0000043, wiring the hooks it backstops), though not a hard dependency.
