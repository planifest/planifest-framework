---
title: "Requirement: REQ-001 - getting-started-restructure"
summary: "getting-started.md slimmed to steps 1–5 only — lean onboarding without operational detail."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-001 - getting-started-restructure

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user reading getting-started.md, I see a lean 5-step onboarding guide, so that I can set up Planifest without wading through operational detail.

---

## Functional Requirements
- `planifest-framework/getting-started.md` covers steps 1–5 only: copy framework, create project structure, run setup, start the orchestrator, and a quick-reference index
- Operational content (commit policy, migration management, updating, customisation) is absent from this file — it lives in project-operations.md and pipeline-reference.md
- Cross-references from getting-started.md point to the correct files for deeper detail

## Acceptance Criteria
- [ ] `planifest-framework/getting-started.md` exists and contains exactly steps 1–5
- [ ] No operational detail (git commit policy, updating, migrations) appears in the file
- [ ] All cross-references resolve to existing files

## Dependencies
- REQ-003 (project-operations.md must exist for cross-references to resolve)

> **Status: IMPLEMENTED** — delivered via patch 001 (commit 9d6a2f2).
