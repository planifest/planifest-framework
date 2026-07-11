---
title: "Requirement: REQ-015 - Design-Defect Report"
summary: "Structured, auditable artifact for a P3/P4 agent blocked by an upstream design defect."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-015 - Design-Defect Report

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-015
**Priority:** must-have
**Wave:** 1

---

## User Story

As a P3/P4 agent hitting a wall caused by an upstream artifact, I file a structured defect report (what is blocked, which criterion/ADR binds, what was attempted, evidence) into `plan/current/`, so that reversal requests are auditable artifacts, not conversational appeals.

---

## Functional Requirements
- A `defect-report.template.md` exists: blocked requirement/task, the binding upstream artifact (criterion, ADR, spec section) with exact reference, attempts made (≥1 required), evidence (test output, error, contradiction), and proposed correction scope
- Reports are filed to `plan/current/defect-reports/{seq}-{slug}.md`; filing halts the reporting agent's current task and hands control to the orchestrator
- A report against an already-denied defect (same binding artifact + same blockage) is detected by the orchestrator and escalated straight to the human on the second attempt
- Reports are only valid from phases P3–P6 against artifacts of P0–P2 (or earlier P3 output for P4+); nothing archived at P7 can be the subject of a report

## Acceptance Criteria
- [ ] Template exists with all five required sections; an incomplete report is returned to the filer, not assessed
- [ ] A duplicate petition for a previously denied defect escalates to the human instead of re-entering assessment
- [ ] Filing is recorded in the build log and (when enabled) emits `phase_reversal_petitioned`

## Dependencies
- REQ-011 (event type), REQ-016 (assessor consumes reports)
