---
title: "Requirement: REQ-012 - One-Question-at-a-Time as Framework-Wide Core Instruction"
summary: "All phase skills enforce one question per response and recommend-then-confirm throughout."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-012 - One-Question-at-a-Time as Framework-Wide Core Instruction

**Skill:** planifest-orchestrator, planifest-spec-agent, planifest-adr-agent, planifest-codegen-agent, planifest-validate-agent, planifest-security-agent, planifest-docs-agent, planifest-ship-agent, planifest-change-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001, US-002, US-003
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- Every phase skill enforces a single rule: at most one question per agent response, across all phases P0–P9
- The rule is stated explicitly in each skill file as a named instruction (e.g. "**One-question rule:** Never ask more than one question per response. Wait for the answer before proceeding.")
- When input is needed, the agent makes a recommendation and asks the human to confirm or override — it does not ask open-ended questions (e.g. "what do you want to do?")
- During P0, the orchestrator additionally walks happy/sad/bad path scenarios before scope locks (REQ-010) — the one-question rule applies throughout this walk
- The instruction applies to all agent-to-human interactions: coaching questions, gate confirmations, escalations, and warnings
- Exception: presenting a list of findings or a summary table is not a question — multi-item output is permitted when it is informational, not interrogative

## Acceptance Criteria
- [ ] Each of the 9 phase skills contains an explicit one-question rule statement
- [ ] No phase skill response asks more than one question per turn in any coaching, gate, or escalation scenario
- [ ] All questions are framed as recommendation + confirmation, not open-ended
- [ ] P0 orchestrator walks happy/sad/bad scenarios one question at a time (REQ-010)
- [ ] Exception for informational multi-item output is documented in the instruction

## Dependencies
- REQ-010 (Scope Lock Challenge applies the rule)
- REQ-011 (audit trail captures each question-answer pair)
