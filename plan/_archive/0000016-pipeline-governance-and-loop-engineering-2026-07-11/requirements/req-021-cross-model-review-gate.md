---
title: "Requirement: REQ-021 - Cross-Model Review Gate (Pre-Archive)"
summary: "A REJECT-default reviewer that is not the implementing model approves the diff before P7 archive."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-021 - Cross-Model Review Gate (Pre-Archive)

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-021
**Priority:** must-have
**Wave:** 1

---

## User Story

As the orchestrator at the end of P6, before P7 archive begins, I obtain approval from a REJECT-default reviewer that is not the implementing model, iterating implement→review→fix until approval or cap — while implementation is still fully live and editable, never after archive — so that the final gate has genuinely different blind spots from the maker.

---

## Functional Requirements
- The gate runs at the end of P6, strictly before any P7 archive action; it is impossible to invoke it against archived state
- The reviewer is a fresh-context subagent on a different model than the one that implemented (model resolved from the tier table; "different" means at minimum a different model id, cross-vendor deferred)
- REJECT-default rubric over the full feature diff + requirements; findings drive an implement→review→fix loop per loop-runner, cap 3, no-progress halt
- On cap or halt without approval, the gate blocks P7 and escalates to the human with the reviewer's outstanding findings; toggle-gated (`cross_model_review`, default off)
- Reviewer verdict artifacts are written to `plan/current/` and their cost/catch-rate reported by P8

## Acceptance Criteria
- [ ] The gate demonstrably runs before P7 (ordering asserted in orchestrator/ship-agent control flow; never after archive)
- [ ] The reviewing model id differs from the implementing model id, recorded in the verdict artifact
- [ ] Cap-without-approval blocks P7 and escalates with findings

## Dependencies
- REQ-009, REQ-010, REQ-011
