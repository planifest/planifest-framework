---
title: "Requirement: REQ-019 - Reversal Human Gates"
summary: "Human approval points that no run mode can bypass: altering reversals, P0 re-exit, budget exhaustion, large cascades."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-019 - Reversal Human Gates

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-019
**Priority:** must-have
**Wave:** 1

---

## User Story

As a human operator, I re-confirm before the pipeline moves forward after a reversal unless I authorised a continuous run; reversals classified as *altering*, any re-exit from P0, budget exhaustion, and large invalidation cascades always require my approval regardless of run mode; in continuous run I am notified of every reversal, so that autonomy never silently changes what I signed off.

---

## Functional Requirements
- Interactive mode: every executed reversal stops for human confirmation before the pipeline resumes forward
- Always-stop gates regardless of run mode: (1) reversal classified *altering* (voids continuous-run authorization — the design the human confirmed has changed); (2) any re-exit from P0; (3) reversal budget exhaustion (2/feature); (4) invalidation cascade larger than a threshold defined by ADR
- Continuous mode: non-gating reversals proceed but the human is notified (message + build-log entry) for every one
- Gates are enforced by orchestrator control flow reading deterministic state (verdict classification, budget counter, cascade size) — not by skill prose alone

## Acceptance Criteria
- [ ] An *altering* verdict under continuous run stops for human approval
- [ ] A re-exit from P0 after reversal demands approval even under continuous run; budget counter survives interrupt/resume
- [ ] Continuous-run non-gating reversals produce a human notification and build-log entry

## Dependencies
- REQ-016 (classification), REQ-017 (execution flow), REQ-010 (persisted counters)
