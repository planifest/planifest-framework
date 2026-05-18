---
title: "Requirement: REQ-002 - pipeline-reference-expanded"
summary: "pipeline-reference.md expanded to full step-by-step phase guidance for all pipeline phases."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - pipeline-reference-expanded

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-002
**Priority:** must-have

---

## User Story

As a framework user reading pipeline-reference.md, I find comprehensive step-by-step phase guidance, so that I have a single authoritative reference for the full pipeline.

---

## Functional Requirements
- `planifest-framework/pipeline-reference.md` contains detailed step-by-step guidance for every pipeline phase
- File includes: what each phase skill does, what artifacts it produces, gate criteria, commit expectations, and what to do when a phase fails
- `plan/archive` references corrected to `plan/_archive` throughout this file
- File updated to reflect the P0–P9 phase structure once REQ-007 is implemented

## Acceptance Criteria
- [ ] `planifest-framework/pipeline-reference.md` exists with expanded phase content
- [ ] No occurrence of `plan/archive` (without underscore) in the file
- [ ] Phase list in file matches canonical P0–P9 once REQ-007 is applied

## Dependencies
- REQ-007 (P0–P9 phase numbering — pipeline-reference.md must be updated when P9 is formalised)

> **Status: PARTIALLY IMPLEMENTED** — expanded content delivered via patch 001 (commit 9d6a2f2). P9 addition pending REQ-007/REQ-008.
