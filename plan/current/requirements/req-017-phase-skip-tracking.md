---
title: "Requirement: REQ-017 - Human-directed phase skip recorded to .skips immediately"
summary: "When a human directs the orchestrator to skip a phase, the skip is written to plan/current/.skips immediately."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-017 - Phase skip tracking

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-16; DD-008
**Priority:** must-have

---

## Functional Requirements

- When the human directs the orchestrator to skip a phase (e.g., "skip the ADR phase"), the orchestrator:
  1. Responds: `Px: Skipped by human direction.`
  2. Immediately writes a skip record to `plan/current/.skips` (creates file if absent, appends if exists).
  3. Skip record format: `{YYYY-MM-DD} P{x} {phase-name}: {reason provided by human, or "human direction" if none given}`.
- The write to `.skips` occurs in the same response turn as the skip acknowledgement — not deferred.
- `.skips` is a plain text file, one record per line.
- At Ship time, the ship-agent appends the `.skips` content to the iteration log under `## Skipped Phases` and deletes `.skips` before archiving.
- `.skips` is not deleted before Ship — it survives context resets (it is a file, not in-memory state).

## Acceptance Criteria

- [ ] After a human skip direction, `.skips` file is present with the correct record within the same turn.
- [ ] Multiple skips accumulate correctly (one line per skip, no overwrites).
- [ ] `.skips` content is readable by the resume detection logic (REQ-016).
- [ ] Ship agent reads `.skips`, appends to iteration log, and deletes the file before archiving.

## Dependencies

- REQ-016 (resume detection reads `.skips`).
- Ship agent SKILL.md must specify `.skips` handling at Phase 7.
