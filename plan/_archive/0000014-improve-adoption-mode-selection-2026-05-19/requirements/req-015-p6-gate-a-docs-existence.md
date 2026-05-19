---
title: "Requirement: REQ-015 - P6 Gate A: docs/ Existence Check"
summary: "P6 gate fails if docs/ directory does not exist."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-015 - P6 Gate A: docs/ Existence Check

**Skill:** planifest-docs-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-002
**Priority:** must-have

---

## User Story

As a framework user, I receive a suggested version number after confirming adoption mode, so that I don't have to derive it manually.

---

## Functional Requirements
- At the start of P6, the docs-agent checks whether `docs/` exists
- If `docs/` does not exist, the P6 gate fails immediately with a clear error: "docs/ directory not found — expected to be created at P0. Cannot proceed with documentation phase."
- The error message names the step responsible for creating it (P0 orchestrator) to aid diagnosis
- This gate applies to all pipeline tracks that include P6 (Feature Pipeline, Change Pipeline) — Fast Path skips P6 entirely

## Acceptance Criteria
- [ ] Docs-agent checks `docs/` existence at P6 start
- [ ] Missing `docs/` produces a named gate failure, not a silent error
- [ ] Error message identifies P0 as the responsible creation step
- [ ] Gate applies to Feature Pipeline and Change Pipeline; not Fast Path

## Dependencies
- REQ-013 (P0 creates docs/ so this gate should never fail in normal operation)
