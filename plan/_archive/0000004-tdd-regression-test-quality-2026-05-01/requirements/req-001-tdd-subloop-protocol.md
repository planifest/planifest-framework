---
title: "Requirement: req-001 - TDD sub-loop protocol in codegen-agent"
status: "active"
version: "0.1.0"
---
# Requirement: req-001 - TDD sub-loop protocol in codegen-agent

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 1 — pipeline operator wants each requirement implemented via red-green-refactor
**Priority:** must-have

---

## Functional Requirements
- The codegen-agent SKILL.md MUST define a TDD inner loop protocol that replaces its current all-at-once test+code approach.
- For each requirement, the codegen-agent MUST orchestrate three sub-agents in sequence: planifest-test-writer → planifest-implementer → planifest-refactor.
- The protocol MUST apply to every functional requirement in `plan/current/requirements/`.
- The codegen-agent MUST load the declared stack capability skill alongside each sub-agent invocation (when the skill exists).
- The codegen-agent MUST retain the full model tier for orchestration and synthesis; sub-agents MAY use a cheaper model tier.

## Acceptance Criteria
- [ ] `planifest-codegen-agent/SKILL.md` contains a documented TDD inner loop protocol section.
- [ ] The protocol specifies the exact invocation sequence: test-writer → implementer → refactor per requirement.
- [ ] The protocol states that stack capability skill is loaded alongside each sub-agent when available.
- [ ] The protocol states that sub-agents SHOULD use a cheaper model tier (haiku-class).
- [ ] The protocol is additive — existing codegen-agent behaviour for multi-component sequencing and deviation/escalation is unchanged.

## Dependencies
- req-002 (planifest-test-writer skill must exist before the protocol can reference it)
- req-003 (planifest-implementer skill)
- req-004 (planifest-refactor skill)
- req-006 (escalation on failure — referenced by this protocol)
