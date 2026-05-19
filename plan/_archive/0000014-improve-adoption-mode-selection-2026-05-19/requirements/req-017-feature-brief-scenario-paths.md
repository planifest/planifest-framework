---
title: "Requirement: REQ-017 - Feature Brief Template: Scenario Paths Section"
summary: "Add Scenario Paths section to feature-brief.template.md to surface happy/sad/bad paths before coaching."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-017 - Feature Brief Template: Scenario Paths Section

**Skill:** planifest-codegen-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- `planifest-framework/templates/feature-brief.template.md` gains a new `## Scenario Paths` section
- The section contains four prompts, each answered before submission:
  - **Happy path:** What does success look like end-to-end?
  - **First-run path:** What happens the very first time this feature is used, before any data or state exists?
  - **Error/sad path:** What are the most likely failure modes, and what should happen when they occur?
  - **Cross-session continuity:** If the pipeline or the user's session is interrupted mid-run, what state is at risk and how is it recovered?
- The section is positioned after user stories and before acceptance criteria, so scenarios inform the criteria
- The orchestrator reads the Scenario Paths section at P0 before beginning coaching — populated answers reduce the number of coaching questions needed; empty answers are treated as gaps to fill during coaching

## Acceptance Criteria
- [ ] `planifest-framework/templates/feature-brief.template.md` contains `## Scenario Paths` section
- [ ] Section contains all four prompts: happy path, first-run path, error/sad path, cross-session continuity
- [ ] Section is positioned after user stories and before acceptance criteria
- [ ] Orchestrator reads and references the section at P0 — populated answers acknowledged, empty ones flagged as coaching gaps

## Dependencies
- REQ-010 (Scope Lock Challenge at P0 complements this by probing further)
- REQ-012 (one-question rule applies when coaching through empty scenario paths)
