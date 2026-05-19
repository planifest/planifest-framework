---
title: "Requirement: REQ-011 - Structured P0 Audit Trail"
summary: "Build log P0 notes capture questions, answers, and deferrals incrementally; feeds P8."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-011 - Structured P0 Audit Trail

**Skill:** planifest-orchestrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001, US-002, US-003
**Priority:** must-have

---

## User Story

As a framework user, I am warned when my adoption mode or version choice conflicts with detected signals, so that I don't make uninformed decisions.

---

## Functional Requirements
- The P0 build log entry is extended with a structured `## P0 Coaching Log` subsection
- Entries are written incrementally — one entry per question-answer exchange — not accumulated and written at P0 close; this prevents data loss if the session interrupts
- Each entry records: question asked, human answer (summary), outcome (accepted / overridden / deferred)
- Deferred items are additionally written to `## Scope → Deferred` in the design document
- Mode selection and version confirmation are both recorded as entries
- Scope Lock Challenge responses are each recorded as entries
- Mid-pipeline change entries include a "could this have been caught at P0?" field — yes / no / partial
- The build-assessment-agent at P8 reads the P0 coaching log to assess coaching quality and surface gaps

## Acceptance Criteria
- [ ] `plan/current/build-log.md` P0 section contains a `## P0 Coaching Log` subsection
- [ ] Entries are written after each question-answer exchange, not at P0 close
- [ ] Each entry has: question, answer summary, outcome
- [ ] Mode selection recorded as an entry
- [ ] Version confirmation recorded as an entry
- [ ] Scope Lock Challenge responses each recorded as entries
- [ ] Mid-pipeline change entries include the "caught at P0?" field
- [ ] P8 build-assessment-agent reads and references the coaching log in its report

## Dependencies
- REQ-010 (Scope Lock Challenge entries feed the log)
- REQ-012 (one-question-at-a-time makes entries discrete and auditable)
