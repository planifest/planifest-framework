---
title: "Requirement: REQ-002 - Explicit Mode Selection Step"
summary: "Adoption mode selection is a distinct, visible step at P0 — not buried in coaching prose."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - Explicit Mode Selection Step

**Skill:** planifest-orchestrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- After detection (REQ-001), the orchestrator presents the recommended mode as a distinct step before coaching begins — not embedded in prose
- The recommendation includes a one-line rationale citing the specific signal that triggered it
- The orchestrator asks the human to confirm or override — one question, one answer
- If the human overrides the recommendation, the agent warns if the choice conflicts with detected signals (REQ-006) and records the override in the P0 audit trail (REQ-011)
- The confirmed mode is written into `plan/current/design.md` under `## Feature → Adoption mode`

## Acceptance Criteria
- [ ] Adoption mode recommendation is presented as a labelled step before any other coaching question
- [ ] Recommendation includes the detection signal cited as rationale (e.g. "`docs/about.md` found → Standard Iterative")
- [ ] Human confirmation or override is solicited as a single question
- [ ] Confirmed mode is written to `plan/current/design.md`
- [ ] Override is recorded in the P0 audit trail with the signal conflict noted

## Dependencies
- REQ-001 (detection must run first)
- REQ-006 (conflict warnings on override)
- REQ-011 (audit trail)
