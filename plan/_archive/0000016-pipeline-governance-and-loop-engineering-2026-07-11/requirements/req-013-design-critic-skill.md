---
title: "Requirement: REQ-013 - Design-Critic Skill (Report-Only)"
summary: "Fresh-context REJECT-default critic reviews P1/P2 artifacts before the human sees them."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-013 - Design-Critic Skill (Report-Only)

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-013
**Priority:** must-have
**Wave:** 1

---

## User Story

As the orchestrator at the end of P1/P2, I spawn a fresh-context `planifest-design-critic` subagent with a REJECT-default rubric that critiques the spec and ADR artifacts before the human sees them, so that the confirmed-design gate reviews hardened artifacts instead of first drafts.

---

## Functional Requirements
- A `planifest-design-critic` skill exists; it is only ever invoked as a fresh-context subagent (Agent tool) loaded with its own skill text plus the artifact paths — never the authoring conversation
- Rubric is REJECT-default: approval requires explicit evidence per rubric item; absence of objection is not approval
- The critic writes a structured verdict artifact to `plan/current/` (findings, severity, approve/reject per artifact); in report-only mode the verdict is presented to the human alongside the artifacts but blocks nothing
- Review-and-revise loop (when promoted beyond report-only): revise → re-review up to cap 3, no-progress halt per loop-runner
- It invokes the mechanical consistency script (REQ-014) first and includes its output as the cheapest verifier layer

## Acceptance Criteria
- [ ] Critic runs as a fresh-context subagent at end of P2 with toggle `design_critic: report-only` and produces a verdict artifact
- [ ] REJECT-default verified: an artifact with no positive evidence for a rubric item is rejected on that item
- [ ] Report-only mode never blocks the pipeline or mutates artifacts

## Dependencies
- REQ-009, REQ-010, REQ-011, REQ-014
