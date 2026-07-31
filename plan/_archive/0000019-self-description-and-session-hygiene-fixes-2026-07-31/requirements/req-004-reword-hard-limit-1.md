---
title: "Requirement: req-004 - reword Hard Limit 1"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-004 - reword Hard Limit 1

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-001 (backlog 0000017, external review REQ-010)
**Priority:** must-have

---

## User Story

As a framework maintainer, I want Hard Limit 1 to state enforceable, falsifiable behaviour, so that a sceptical reader can check the claim rather than take it on trust.

---

## Functional Requirements
- `README.md:109` currently states Hard Limit 1 as "Requirements must be complete before codegen begins" — unachievable in the strict sense and unfalsifiable as written (no observable state demonstrates violation).
- Reword to describe the framework's actual, enforceable behaviour: gaps are surfaced during P0/P1, then either resolved or explicitly recorded as deferred, before code generation begins.
- Align the orchestrator's wording (`.claude/skills/planifest-orchestrator/SKILL.md`, Hard Limit 1) with the README's reworded version.
- The wording must map to an observable artifact in the plan folder (e.g. `plan/current/scope.md`'s Deferred section) so a reader can verify the claim rather than take it on trust.

## Acceptance Criteria
- [ ] README and orchestrator SKILL.md wording for Hard Limit 1 aligned.
- [ ] Reworded claim maps to an observable artifact in `plan/current/` (named explicitly in the wording).

## Dependencies
- Same-file edit as req-001 (0000014, README.md) — free to carry along in the same pass.
