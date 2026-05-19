---
title: "Requirement: REQ-007 - Bug Fix: design.template.md Adoption Mode Field"
summary: "Fix adoption mode field in design.template.md which always persists as 'retrofit'."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-007 - Bug Fix: design.template.md Adoption Mode Field

**Skill:** planifest-codegen-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- Investigate `planifest-framework/templates/design.template.md` to identify why the adoption mode field persists as "retrofit" regardless of the confirmed mode
- Fix the field so it reflects the four valid mode values: `greenfield | standard-iterative | retrofit | external-anchor`
- The fix must not introduce a new default value that could silently persist — the field must remain a placeholder requiring explicit population

## Acceptance Criteria
- [ ] `design.template.md` adoption mode field lists all four valid values: `greenfield | standard-iterative | retrofit | external-anchor`
- [ ] No hardcoded default value exists in the template that could silently populate
- [ ] Root cause of the "always retrofit" bug is identified and documented in a code comment or PR note

## Dependencies
- None — standalone template fix
