---
title: "Requirement: req-002 - fix-envelope-parameter"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-002 - fix-envelope-parameter

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000024-declared-product-id-for-telemetry
**Source:** US-002
**Priority:** must-have

## User Story

As a telemetry consumer, I want the 12 agent-driven event types the framework specifies to actually reach the backend, so that ADR decisions, security findings, deviations, and other quality signals are queryable instead of silently missing.

## Functional Requirements

- `planifest-framework/standards/telemetry-standards.md`'s Event Envelope section (currently lines ~104-127) MUST state explicitly that the `emit_event` MCP tool's top-level call argument is named `envelope`, not `event` — and MUST call out that this is a deliberate gotcha: the envelope's own internal discriminator field is itself named `event` (see the JSON block's `"event": "<event_name>"` line), so the argument name and the field name collide in a way that invites the exact mistake this requirement fixes.
- The corrected section MUST include a usage example showing the correct call shape, i.e. the full envelope object passed under a top-level `envelope` key (for example: `emit_event({ envelope: { schema_version: "1.0", event: "<event_name>", ... } })`), not a flat/`event`-shaped argument.
- All 8 phase skills' `## Telemetry` sections MUST be audited for any place that names or implies the wrong MCP argument name (e.g. any snippet or prose suggesting `emit_event(event: {...})` or otherwise omitting the `envelope` wrapper). The 8 files are: `planifest-framework/skills/planifest-spec-agent/SKILL.md`, `planifest-adr-agent/SKILL.md`, `planifest-codegen-agent/SKILL.md`, `planifest-validate-agent/SKILL.md`, `planifest-security-agent/SKILL.md`, `planifest-docs-agent/SKILL.md`, `planifest-change-agent/SKILL.md`, and `planifest-orchestrator/SKILL.md`.
- Per feature 0000023's ADR-002 ("Telemetry guidance centralised — all envelope docs live in telemetry-standards.md, skill files reference it rather than duplicating"), the 8 skill files are expected to only reference the central doc and not duplicate the argument name — so this audit is expected to find zero fixes needed in those 8 files. That expectation MUST NOT substitute for performing the audit: the audit must actually be run and its outcome (files checked, findings if any, fixes applied if any) documented in the build log or equivalent artifact, not assumed from the ADR alone.
- If the audit does surface a stale or wrong argument reference in any of the 8 files (contrary to expectation), it MUST be fixed as part of this requirement's implementation, using the same corrected `envelope` wording as the central `telemetry-standards.md` fix.
- During this feature's own pipeline run (P2 ADR authoring or P4 validation), at least one real agent-driven event (e.g. `adr_decision` when this feature's new ADR is written at P2) MUST be emitted using the corrected `envelope` argument shape.
- That live-emitted event MUST be confirmed to have landed in the telemetry backend via the `query_telemetry` MCP tool — not assumed successful from a lack of an error response alone.
- This closes the follow-up verification step left open and never executed by feature 0000017's RCA (`plan/_archive/0000017-.../telemetry-mcp-rca-and-fix-spec.md`); the requirement's implementation record MUST note this closure explicitly.

## Acceptance Criteria

- [ ] `telemetry-standards.md`'s Event Envelope section explicitly names `envelope` as the `emit_event` top-level argument, explicitly notes the collision with the envelope's internal `event` discriminator field, and includes a corrected usage example showing the `envelope`-wrapped call shape.
- [ ] All 8 phase skills' `## Telemetry` sections have been read and checked for the wrong-argument-name gap, and the outcome (pass/fail per file) is documented — not assumed from ADR-002 alone.
- [ ] Any wrong-argument-name reference found in the 8 skill files during the audit is fixed to match the corrected `envelope` wording; if none are found, that zero-findings result is recorded rather than left unstated.
- [ ] At least one real agent-driven event (e.g. `adr_decision`) is emitted during this feature's own P2 or P4 using the corrected `envelope` argument shape.
- [ ] That event's landing in the backend is confirmed via a `query_telemetry` call, with the result recorded (e.g. event id or query match) rather than inferred from the emit call's own response alone.
- [ ] If the live re-verification surfaces that Root Cause B from the 0000017 RCA (missing `loop_iteration` / `phase_reversal_*` schema entries in the backend) is still broken, this requirement's implementation does NOT attempt to fix it — fixing it would require changes inside `structured-telemetry-mcp`, which is out of scope for this repo. Instead, a fresh backlog entry is filed describing the finding, and that filing is noted in this requirement's implementation record.

## Dependencies

- req-001 (declared `product_id` sourcing): loose dependency only — both requirements edit `telemetry-standards.md`, but different sections (req-001 touches the `product_id` sourcing description; this requirement touches the Event Envelope argument-name documentation). There is no blocking order between them; either may be implemented first.
