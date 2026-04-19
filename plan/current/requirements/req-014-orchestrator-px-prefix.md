---
title: "Requirement: REQ-014 - Every orchestrator agent response prefixed Px"
summary: "All Planifest pipeline agent responses begin with Px where x is the phase number (P0–P7); change-agent uses PC."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-014 - Every agent response prefixed Px

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-13; DD-008
**Priority:** must-have

---

## Functional Requirements

- Every response produced by a Planifest pipeline agent (orchestrator, spec-agent, adr-agent, codegen-agent, validate-agent, security-agent, docs-agent, ship-agent) begins with `Px:` where `x` is the pipeline phase number (0–7).
- The orchestrator's own responses use the phase it is currently facilitating (e.g., `P0:` during Phase 0, `P3:` when facilitating codegen).
- The change-agent uses `PC:` (Change Pipeline) on every response — it is not a numbered pipeline phase.
- The ship-agent uses `P7:` on every response.
- Phase opens: `Px: Starting {phase-name} — {one-liner}`.
- Phase closes: `Px: {phase-name} complete. Artefacts: {list}. Next: {next-phase-name}.`
- Escalation messages: `Px: ⚠ {escalation message}`.
- This convention is documented in the SKILL.md for every affected agent and in `getting-started.md`.

## Acceptance Criteria

- [ ] All 8 agent SKILL.md files include the Px prefix rule.
- [ ] `getting-started.md` "Understanding phase indicators" section describes Px convention.
- [ ] Phase open and close formats are specified in the orchestrator SKILL.md.
- [ ] Change-agent SKILL.md specifies `PC:` prefix.

## Dependencies

- REQ-018 (getting-started.md update must include the Px section).
