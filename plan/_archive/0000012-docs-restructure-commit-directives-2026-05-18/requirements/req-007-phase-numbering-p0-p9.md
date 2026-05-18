---
title: "Requirement: REQ-007 - phase-numbering-p0-p9"
summary: "Pipeline formally P0–P9; P7=Archive, P8=Build Assessment, P9=Ship. No invented phase numbers."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-007 - phase-numbering-p0-p9

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-007
**Priority:** must-have

---

## User Story

As a pipeline agent, I reference only canonical phases P0–P9 in all output, so that invented phase numbers never appear and every phase has a defined purpose.

---

## Functional Requirements
- `planifest-framework/skills/planifest-orchestrator/SKILL.md` Response Prefix Convention table is updated to list exactly 10 phases: P0 Assess & Coach, P1 Spec, P2 ADRs, P3 Codegen, P4 Validate, P5 Security, P6 Docs, P7 Archive, P8 Build Assessment, P9 Ship — the table is annotated as the complete and exhaustive list
- A new Hard Limit is added: "The pipeline has exactly 10 phases: P0–P9. There is no phase beyond P9. Never cite a phase number outside this range."
- All references to P7 "Ship" in the orchestrator SKILL.md are renamed to P7 "Archive"
- All references to P8 "Build Assessment" retain their name
- P9 "Ship" section is added (details in REQ-008)
- `planifest-framework/pipeline-reference.md` phase list updated to P0–P9 with correct names
- `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md` updated to clarify it is invoked as a sub-agent by the ship-agent, not directly by the orchestrator

## Acceptance Criteria
- [ ] planifest-orchestrator/SKILL.md Response Prefix Convention table lists exactly P0–P9 with correct phase names
- [ ] Table is annotated as complete and exhaustive
- [ ] Hard Limit present: pipeline has exactly 10 phases, P0–P9, no phase beyond P9
- [ ] All P7 "Ship" references renamed to P7 "Archive" in orchestrator SKILL.md
- [ ] pipeline-reference.md phase list matches P0–P9
- [ ] planifest-build-assessment-agent/SKILL.md clarifies sub-agent invocation by ship-agent

## Dependencies
- REQ-008 (P9 Ship section content is defined there; this requirement handles the structural change)
