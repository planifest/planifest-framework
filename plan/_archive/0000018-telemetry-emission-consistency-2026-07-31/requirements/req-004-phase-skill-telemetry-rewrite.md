---
title: "Requirement: req-004 - phase-skill-telemetry-rewrite"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-004 - phase-skill-telemetry-rewrite

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000018-telemetry-emission-consistency
**Source:** US-001, US-002
**Priority:** must-have

---

## User Story

As a human running a Planifest pipeline with telemetry enabled, I see every event the phase skills specify actually emitted during the run, so that the collected data reflects real pipeline behavior, not whatever an agent happened to remember.

---

## Functional Requirements
- Rewrite the "Telemetry" section in each of the 8 phase skills (`planifest-orchestrator`, `planifest-spec-agent`, `planifest-adr-agent`, `planifest-codegen-agent`, `planifest-validate-agent`, `planifest-change-agent`, `planifest-security-agent`, `planifest-docs-agent`) so that an agent-driven emission failure triggers the immediate stop-and-ask protocol (req-003) rather than the current "skip silently if unavailable" instruction. (Corrected from the original spec, which named `planifest-ship-agent` — verification at implementation time showed `ship-agent`'s Telemetry section already deferred fully to `telemetry-standards.md` with no local gate line, so it never had the soft-skip language to begin with; `planifest-change-agent` is the real 8th affected skill.)
- Remove the "skip silently if unavailable" language everywhere it currently appears across these 8 skills
- Keep the full event envelope and schema documentation centralized in `telemetry-standards.md` (per ADR-002, 0000007) — each skill's Telemetry section references the standard, it does not duplicate the envelope shape

## Acceptance Criteria
- [ ] All 8 phase skills' Telemetry sections are updated with matching interactive-failure language
- [ ] No skill duplicates the full event envelope schema — each still points to `telemetry-standards.md`
- [ ] The phrase "skip silently if unavailable" (or equivalent soft-skip language) no longer appears in any of the 8 skills

## Dependencies
- req-003 — the interactive protocol these skills now reference must be defined first
