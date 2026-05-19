---
title: "Requirement: REQ-006 - Conflict Warnings"
summary: "Agent warns when human's mode or version choice conflicts with detected signals."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-006 - Conflict Warnings

**Skill:** planifest-orchestrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-003
**Priority:** must-have

---

## User Story

As a framework user, I am warned when my adoption mode or version choice conflicts with detected signals, so that I don't make uninformed decisions.

---

## Functional Requirements
- When the human selects an adoption mode that differs from the detected mode, the orchestrator issues a specific warning naming the conflicting signal and what it implies
- When the human confirms a version that is lower than the current recorded version, the orchestrator blocks the confirmation with a hard error (not a warning) — REQ-009 governs the block
- When the human selects Greenfield but `external-versioning.md` is present, the orchestrator warns that External Anchor must take priority and rejects the override
- All warnings are one sentence, specific, and cite the signal by name
- After a warning, the orchestrator asks the human to confirm they wish to proceed — one question

## Acceptance Criteria
- [ ] Warning is issued when human's mode differs from detected mode, citing the specific signal
- [ ] External Anchor cannot be overridden — orchestrator rejects the attempt and explains why
- [ ] Version regression produces a hard block, not a warning (see REQ-009)
- [ ] Each warning is followed by a single confirmation question before proceeding
- [ ] Override confirmation is recorded in P0 audit trail (REQ-011)

## Dependencies
- REQ-001 (detection signals to cite)
- REQ-009 (version regression hard block)
- REQ-011 (audit trail of overrides)
