---
title: "Requirement: req-003 - honest CI parity wording"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-003 - honest CI parity wording

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-001 (backlog 0000016, external review REQ-003)
**Priority:** must-have

---

## User Story

As a framework maintainer, I want the CI parity check's guarantee described accurately, so that it isn't oversold as something it doesn't verify.

---

## Functional Requirements
- The parity check (`.github/workflows/planifest.yml:37`, `hooks/pre-push:38`, `hooks/pre-commit:8`) proves only that *some* file under `plan/` or `docs/` changed in the same PR — it does not prove documentation corresponds to the code changed. It is a presence heuristic, not a correspondence guarantee.
- Reword the CI failure message (currently implies "Code modified without corresponding updates to plan/, docs/, or component.yml" — a correspondence claim that is never checked) to state plainly what was and was not checked.
- Apply the same rewording to the equivalent strings in `hooks/pre-push` and `hooks/pre-commit`.
- Align the README Hard Limits and Limitations sections with the same distinction.

## Acceptance Criteria
- [ ] CI failure message reworded to state what was and was not checked (presence, not correspondence).
- [ ] The same rewording applied to `hooks/pre-push` and `hooks/pre-commit`.
- [ ] README Hard Limits and Limitations sections reflect the same distinction.

## Dependencies
- Shares file scope with req-002 (0000015) — both edit the same hook/workflow strings; sequence-safe to implement together.
