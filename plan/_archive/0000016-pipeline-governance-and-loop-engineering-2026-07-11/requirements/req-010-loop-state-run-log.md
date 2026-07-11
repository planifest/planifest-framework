---
title: "Requirement: REQ-010 - Loop State and Run-Log Conventions"
summary: "Schema'd loop-state file plus append-only run log so loops survive context resets and are auditable."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-010 - Loop State and Run-Log Conventions

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-010
**Priority:** must-have
**Wave:** 1

---

## User Story

As a looping agent, I read/write a schema'd loop-state file and append to a run log (one structured record per iteration: action, observation, decision continue/done/escalate), so that loops survive context resets and runs can be audited and compared.

---

## Functional Requirements
- A `loop-state.template.md` exists: loop id, owning phase, iteration counter, cap, budget counters (shared reversal budget reference), last decision, and escalation context section
- A `loop-run-log` convention exists: append-only, one structured record per iteration with fields `action`, `observation`, `decision (continue|done|escalate)`, timestamp
- Both live under `plan/current/` and are git-tracked; an interrupted session resumes mid-loop by reading state per the existing `Px: Resuming…` convention
- Budget counters (e.g. reversal budget 2/feature) are persisted in the state file so interrupt/resume cannot reset them

## Acceptance Criteria
- [ ] Templates exist for loop-state and run-log record; loop-runner references them
- [ ] A simulated interrupt/resume preserves iteration counter and budget counters
- [ ] Run-log records are append-only (no iteration record is ever rewritten)

## Dependencies
- REQ-009 (loop-runner prescribes when these are written)
