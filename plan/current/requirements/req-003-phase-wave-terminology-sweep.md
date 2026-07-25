---
title: "Requirement: req-003 - phase-wave-terminology-sweep"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-003 - phase-wave-terminology-sweep

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Source:** US-003
**Priority:** should-have

---

## User Story

As anyone reading Planifest docs, I see "Phase" and "Wave" used correctly and consistently everywhere, so that the pipeline-phase sense (P0-P9) is never confused with the decomposition sense.

---

## Functional Requirements
- Review every instance of "Phase" and "Wave" across `plan/current/`, `docs/`, `planifest-framework/`, and root `README.md`
- Correct only decomposition-sense usages that incorrectly say "Phase" instead of "Wave"; leave pipeline-phase-sense usages (P0-P9) unchanged
- Exclude `plan/_archive/` and `plan/changelog/` (historical/immutable records) and `CLAUDE.md` (generated/refreshed from `planifest-framework/` source — fixing the source propagates automatically)
- Produce a report listing every reviewed instance: correct-as-is or corrected, and what changed

## Acceptance Criteria
- [ ] Report lists every instance of "Phase"/"Wave" found across the 4 in-scope path prefixes
- [ ] Each listed instance is marked correct-as-is or corrected, with the correction shown
- [ ] No blind find-and-replace — every instance individually reviewed in context
- [ ] Excluded paths (`plan/_archive/`, `plan/changelog/`, `CLAUDE.md`) are untouched

## Dependencies
- None — self-contained documentation review
