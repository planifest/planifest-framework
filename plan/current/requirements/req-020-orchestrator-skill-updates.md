---
title: "Requirement: REQ-020 - Orchestrator SKILL.md updated for Phase 7 and all UX changes"
summary: "The orchestrator SKILL.md gains Phase 7 Ship routing, Px prefix rules, resume detection, and hooks-as-primary-emission note."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-020 - Orchestrator SKILL.md updates

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief Track A + Track D scope
**Priority:** must-have

---

## Functional Requirements

- Orchestrator SKILL.md is updated to include:
  1. **Phase 7 Ship routing:** `| Begin Phase 7 (Ship) | Load the planifest-ship-agent skill |` row in the phase routing table.
  2. **Px prefix rule:** "Every response begins with `Px:` where x is the current pipeline phase."
  3. **Phase open/close format:** `Px: Starting {phase-name} — {one-liner}` / `Px: {phase-name} complete. Artefacts: {list}. Next: {next-phase-name}.`
  4. **Phase 0 briefing steps** (DD-007): phase table, tool detection, hooks health check, Tier 3 warning.
  5. **Resume detection logic** (DD-009): artefact scan, resume message format, skip acknowledgement.
  6. **Skip recording** (DD-008): write to `.skips` immediately on human skip direction.
  7. **Telemetry note:** hooks are the primary emission mechanism for `phase_start`/`phase_end`; SKILL.md telemetry instructions are backup for tools without hooks.
  8. **Phase name update:** Phase 7 renamed from "Change" to "Ship" throughout.

## Acceptance Criteria

- [ ] Orchestrator SKILL.md has a Phase 7 row routing to planifest-ship-agent.
- [ ] Orchestrator SKILL.md documents the Px prefix rule.
- [ ] Orchestrator SKILL.md includes Phase 0 briefing steps with tool detection priority.
- [ ] Orchestrator SKILL.md includes resume detection logic.
- [ ] Telemetry section notes hooks as primary, instructions as backup.

## Dependencies

- REQ-014 (Px convention), REQ-015 (Phase 0 briefing), REQ-016 (resume detection), REQ-019 (ship-agent must exist).
