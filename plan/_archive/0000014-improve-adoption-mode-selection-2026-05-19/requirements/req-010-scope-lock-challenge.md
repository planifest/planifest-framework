---
title: "Requirement: REQ-010 - Scope Lock Challenge"
summary: "Structured happy/sad/bad path scenario exploration before design gate closes."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-010 - Scope Lock Challenge

**Skill:** planifest-orchestrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001, US-002, US-003
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- Before presenting the confirmed design for human sign-off, the orchestrator runs a Scope Lock Challenge
- The orchestrator derives relevant happy/sad/bad path scenarios from the specific feature being built — not a fixed checklist
- Scenarios are presented one at a time (REQ-012); the orchestrator waits for each answer before asking the next
- When a scenario question surfaces a new requirement: (1) orchestrator records it immediately ("noted — adding to design"), (2) asks one or two clarifying questions to make it concrete, (3) explicitly resumes the challenge: "Back to the scenarios — [restates where we were]"
- When the human gives a vague "no" answer, the orchestrator probes once before accepting: one follow-up question
- When the human defers an item ("I'll deal with it later"), the item is recorded as a formal deferred entry in `## Scope → Deferred` in the design and in the P0 build log — verbal acknowledgement is not sufficient
- The Scope Lock Challenge runs after all coaching is complete and before the design is presented for confirmation

## Acceptance Criteria
- [ ] Scope Lock Challenge runs for every new feature pipeline before design confirmation
- [ ] Scenarios are derived from the specific feature, not a generic list
- [ ] One scenario presented per turn
- [ ] New items surfaced during challenge are captured immediately with brief clarification, then challenge resumes
- [ ] Vague "no" answers receive one follow-up probe before acceptance
- [ ] Deferred items are written to `## Scope → Deferred` and the P0 build log
- [ ] Challenge does not run for Fast Path or Change Pipeline (not applicable)

## Dependencies
- REQ-011 (audit trail for deferrals)
- REQ-012 (one-question-at-a-time enforcement)
