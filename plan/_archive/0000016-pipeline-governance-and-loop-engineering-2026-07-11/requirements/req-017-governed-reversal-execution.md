---
title: "Requirement: REQ-017 - Governed Reversal Execution"
summary: "A granted reversal is a scoped delta: rev-bump, scoped re-run, invalidation cascade — within P0–P6."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-017 - Governed Reversal Execution

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-017
**Priority:** must-have
**Wave:** 1

---

## User Story

As the orchestrator executing a granted reversal, I rev-bump the affected artifacts with a revision-log entry, run the target phase's agent scoped to the defect, compute the invalidation cascade from traceability, and resume forward re-doing only invalidated work — entirely within P0–P6, before anything is archived — so that a reversal is a scoped delta, not a pipeline restart.

---

## Functional Requirements
- On grant: affected artifacts get a version bump plus an entry in `plan/current/revision-log.md` (a `revision-log` entry template exists: artifact, old→new version, defect-report reference, date)
- The owning phase's agent is re-invoked scoped only to the defect (self-contained prompt naming the artifact sections to revise) — not a full phase re-run
- The invalidation cascade is computed from existing story↔requirement↔component traceability: only artifacts downstream of the revised sections are re-done; the cascade list is written into the verdict record before any re-work starts
- Reversal budget (2/feature) is decremented in the loop-state file on grant; the entire flow is inoperable on anything archived at P7+
- After the scoped re-run, the pipeline resumes forward from the reversal's owning phase, re-doing only cascade-listed work

## Acceptance Criteria
- [ ] A seeded end-to-end reversal executes petition → verdict → rev-bump + revision-log → scoped re-run → cascade re-do → forward resume
- [ ] Artifacts not on the cascade list are byte-identical before/after the reversal
- [ ] Budget decrements on grant and survives session interrupt/resume

## Dependencies
- REQ-010 (budget persistence), REQ-015, REQ-016, REQ-018 (ratchet guards the re-writes), REQ-019 (human gates)
