---
title: "Requirement: req-008 - document backlog ID sequence convention"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-008 - document backlog ID sequence convention

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Source:** US-004 (backlog 0000026)
**Priority:** should-have

---

## User Story

As an agent filing a backlog entry, I want the ID-sequence convention documented where I'll actually meet it, so that I don't have to reverse-engineer the rule or risk corrupting the sequence.

---

## Functional Requirements
- State explicitly, in `planifest-framework/templates/backlog-entry.template.md` and in the orchestrator's P0 backlog-pickup step (`.claude/skills/planifest-orchestrator/SKILL.md`), that backlog IDs are allocated from their own monotonic sequence, independent of feature IDs.
- State that collisions with feature IDs are expected and must not be "corrected" (this feature, 0000019, collides in number with backlog item 0000019 — a live example).
- State that the next ID is the highest ever allocated plus one, counting entries already picked up or discarded — not merely the highest currently present in `plan/backlog/`.
- Consider (not mandatory for this requirement) persisting the last allocated ID in a marker file (e.g. `plan/backlog/.last-id`) so allocation is a read rather than an archive scan — leave as a noted option if not implemented now.

## Acceptance Criteria
- [ ] `backlog-entry.template.md` states the independent-sequence rule.
- [ ] Orchestrator P0 backlog-pickup step states the same rule, including the "highest ever allocated, not highest present" clarification.
- [ ] Both locations explicitly state that ID collisions with feature IDs are expected, not a defect.

## Dependencies
- None.
