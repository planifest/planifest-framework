---
title: "Requirement: REQ-003 - project-operations-new-file"
summary: "New project-operations.md file providing a concise ops reference for running projects."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - project-operations-new-file

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-003
**Priority:** must-have

---

## User Story

As a framework user reading project-operations.md, I find a concise ops reference, so that I can manage running projects without re-reading the full pipeline.

---

## Functional Requirements
- `planifest-framework/project-operations.md` exists as a new file
- File covers: git commit policy, updating planifest-framework, running migrations, customising with planifest-overrides, what to commit to git
- File is brief — links to pipeline-reference.md for detail rather than duplicating it
- `plan/archive` references corrected to `plan/_archive` throughout this file

## Acceptance Criteria
- [ ] `planifest-framework/project-operations.md` exists
- [ ] File covers commit policy, updating, migrations, overrides, and what to commit
- [ ] No occurrence of `plan/archive` (without underscore) in the file
- [ ] File links to pipeline-reference.md for deeper detail, not duplicates it

## Dependencies
- REQ-002 (pipeline-reference.md must exist as the target of cross-references)

> **Status: IMPLEMENTED** — delivered via patch 001 (commit 9d6a2f2).
