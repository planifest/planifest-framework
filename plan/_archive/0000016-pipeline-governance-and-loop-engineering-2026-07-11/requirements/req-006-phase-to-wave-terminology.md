---
title: "Requirement: REQ-006 - Phase-to-Wave Terminology Fix"
summary: "Rename feature-decomposition grouping from 'Phase' to 'Wave' to end the collision with P0–P9."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-006 - Phase-to-Wave Terminology Fix

**Skill:** planifest-docs-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-006
**Priority:** should-have
**Wave:** 0

---

## User Story

As a framework maintainer, I rename the feature-decomposition grouping concept from "Phase" to "Wave" in `feature-brief.template.md` and the orchestrator's Decomposition section, so that it no longer collides with the P0–P9 pipeline-phase terminology.

---

## Functional Requirements
- `planifest-framework/templates/feature-brief.template.md`: every use of "Phase" meaning a decomposition group becomes "Wave" (table headers, prose, examples)
- Orchestrator SKILL.md Decomposition section: "Phases" grouping concept renamed to "Waves", including coaching prompts
- P0–P9 pipeline-phase terminology, the `Px:` prefix convention, and phased-feature artifact suffixes that refer to pipeline runs are NOT renamed
- Spec-agent "Phased Features" section reviewed: where "phase" means decomposition wave, rename; where it means pipeline run sequencing, keep

## Acceptance Criteria
- [ ] Grep for decomposition-sense "Phase" in the brief template and orchestrator Decomposition section returns zero hits post-change
- [ ] All P0–P9 references and the Response Prefix Convention are untouched

## Dependencies
- None
