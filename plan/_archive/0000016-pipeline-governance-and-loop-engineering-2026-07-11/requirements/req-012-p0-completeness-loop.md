---
title: "Requirement: REQ-012 - P0 Completeness Loop"
summary: "P0 exits only when an explicit structured gap checklist passes; same-gap-twice escalates."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-012 - P0 Completeness Loop

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-012
**Priority:** must-have
**Wave:** 1

---

## User Story

As the orchestrator in P0, I coach against an explicit structured gap checklist and exit P0 only when it passes, escalating `P0: Blocked` if the same gap survives 2 coaching rounds, so that completeness is checkable rather than conversational.

---

## Functional Requirements
- The existing Phase 0 → Phase 1 Gate Checklist becomes the loop's pass condition: each coaching round re-evaluates the full checklist and records pass/fail per item in the loop run log
- If the same checklist item fails after 2 coaching rounds, the orchestrator emits `P0: Blocked — {item}` with the escalation context rather than asking a third time
- The loop is toggle-gated (`p0_completeness`, default off); when off, P0 behaves exactly as today
- Loop mechanics (state, run log, stop rules) come from loop-runner — not redefined in the orchestrator

## Acceptance Criteria
- [ ] With the toggle on, each coaching round appends a checklist evaluation to the run log
- [ ] A gap surviving 2 rounds produces `P0: Blocked` escalation, not a third identical question
- [ ] With the toggle off, P0 output is unchanged from pre-feature

## Dependencies
- REQ-009, REQ-010, REQ-011
