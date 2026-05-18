---
title: "Requirement: REQ-005 - build-log-enforcement"
summary: "Hard Limit in orchestrator requiring a build log entry at every phase start and gate."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-005 - build-log-enforcement

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-005
**Priority:** must-have

---

## User Story

As a pipeline agent, I write a build log entry at every phase start and gate, so that P8 always has complete data to analyse.

---

## Functional Requirements
- `planifest-framework/skills/planifest-orchestrator/SKILL.md` adds a new Hard Limit (numbered sequentially after existing limits): "Write a build log entry at the start of every phase and at every phase gate. A missing entry is a pipeline error — stop and write it before proceeding."
- The Hard Limit explicitly names: create `plan/current/build-log.md` at P0 start if absent; append a phase block at every phase start (Px: Starting) and gate (Px: Complete)
- The existing Phase 0 Start Actions section reinforces: "Create build log" is step 2 and mandatory, not optional
- The existing build log maintenance instruction in the orchestrator ("At the start of every phase (P0–P8), append a new phase block") is updated to cover P0–P9

## Acceptance Criteria
- [ ] planifest-orchestrator/SKILL.md has a Hard Limit requiring build log entry at every phase
- [ ] Hard Limit explicitly states a missing entry is a pipeline error
- [ ] Phase 0 Start Actions step 2 (build log creation) is marked mandatory
- [ ] Build log phase range updated to P0–P9

## Dependencies
- REQ-007 (phase range P0–P9 must be confirmed before updating the range in this directive)
