---
title: "Requirement: REQ-018 - Ratchet Hook"
summary: "Deterministic hook blocking silent weakening of acceptance criteria or scope during loops/reversals."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-018 - Ratchet Hook

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-018
**Priority:** must-have
**Wave:** 1

---

## User Story

As a pipeline operator, I have a deterministic hook that diffs acceptance criteria and scope sections on artifact writes during loops/reversals and blocks silent weakening or descoping, so that loops cannot pass their verifiers by moving the goalposts.

---

## Functional Requirements
- A `ratchet-check.mjs` PreToolUse hook (Write|Edit) exists in the same family as `gate-write.mjs`, active only while a loop or reversal is in flight (loop-state file present and active)
- It diffs `## Acceptance Criteria` and scope sections of `plan/current/` artifacts being written: removal of a criterion, weakening edits (deleting a checklist item, loosening a stated numeric target), or moving in-scope items to out-of-scope count as weakening
- Weakening → exit 2 with a human-readable reason naming the removed/weakened line; the attempt is appended to the run log and (when enabled) emitted to telemetry for P8 reporting
- Strengthening (adding criteria, tightening targets, adding scope explicitness) → exit 0; human-approved weakening proceeds via an explicit approval marker the human adds (mechanism decided by ADR)
- Unexpected errors exit 0 (hooks never block a session unexpectedly), matching the existing hook error contract

## Acceptance Criteria
- [ ] A seeded criteria-weakening write is blocked with a message naming the weakened line
- [ ] A seeded strengthening write passes
- [ ] Attempted weakenings appear in the run log and P8 build assessment

## Dependencies
- REQ-010 (loop-state file arms the hook), REQ-011 (telemetry event)
