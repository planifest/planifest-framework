---
title: "Requirement: req-005 - telemetry-standards-extraction"
status: "active"
version: "0.1.0"
---
# Requirement: req-005 — Extract telemetry boilerplate to telemetry-standards.md

**Feature:** 0000007-agent-optimisation
**Source:** Confirmed optimisation items req-002 + req-004 from live optimise-agent review
**Priority:** must-have

---

## Functional Requirements

- Create `planifest-framework/standards/telemetry-standards.md` containing:
  1. **Full event envelope structure** — the complete JSON object with fields: `schema_version`, `event`, `agent`, `phase`, `tool`, `model`, `mcp_mode`, `session_id`, `timestamp`, `data`
  2. **Emission gate conditions** — "Emission is mandatory when both conditions are met. If either condition fails, skip silently — do not emit. 1. `emit_event` tool is present in this session. 2. `.claude/telemetry-enabled` exists in the project root."
  3. **phase_start / phase_end ownership note** — "phase_start and phase_end are emitted by the orchestrator, not phase skills. The orchestrator emits phase_start before invoking a skill and phase_end after it completes."

- In each of the following skills, replace the three blocks above with a single pointer line:
  `"See planifest-framework/standards/telemetry-standards.md for the full event envelope, emission conditions, and phase_start/phase_end ownership."`

  Target skills: `planifest-orchestrator`, `planifest-spec-agent`, `planifest-adr-agent`, `planifest-codegen-agent`, `planifest-validate-agent`, `planifest-security-agent`, `planifest-docs-agent`, `planifest-ship-agent`, `planifest-change-agent`

- Per-skill event definitions (e.g. `validation_failure`, `self_correction`, `adr_decision`) MUST remain in each skill — only the envelope, gate conditions, and phase_start/phase_end note are extracted

## Acceptance Criteria

- [ ] `planifest-framework/standards/telemetry-standards.md` exists with all three components (envelope, gate conditions, phase_start/phase_end note)
- [ ] Each of the 9 target skills has a single pointer line replacing the three extracted blocks
- [ ] Per-skill event definitions are unchanged in all 9 skills
- [ ] No skill file contains the full envelope JSON object

## Dependencies

- None — this is a refactor with no functional change to telemetry behaviour
