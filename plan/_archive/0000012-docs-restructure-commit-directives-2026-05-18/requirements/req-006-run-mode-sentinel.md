---
title: "Requirement: REQ-006 - run-mode-sentinel"
summary: "Orchestrator writes plan/.run-mode at P0 and records gate acceptance in interactive runs."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-006 - run-mode-sentinel

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-006
**Priority:** must-have

---

## User Story

As a pipeline orchestrator, I write a run-mode sentinel file at P0 and record explicit human acceptance at each interactive phase gate, so that the run mode and gate acceptance history are permanently recorded.

---

## Functional Requirements
- At P0, after the human answers the continuous-run question, the orchestrator writes `plan/.run-mode` containing either `continuous` or `interactive`
- In interactive runs (`plan/.run-mode` = `interactive`): at each phase gate where the human confirms, the orchestrator appends a gate acceptance record to `plan/current/build-log.md` in the format: `Gate accepted: P{N} — {ISO-8601 timestamp}`
- In continuous runs (`plan/.run-mode` = `continuous`): no gate acceptance record is written; the sentinel file is the record
- On resume detection, the orchestrator reads `plan/.run-mode` to restore the run mode without re-asking the human
- `plan/.run-mode` is committed as part of the P0 plan commit

## Acceptance Criteria
- [ ] planifest-orchestrator/SKILL.md writes `plan/.run-mode` at P0 after run-mode is confirmed
- [ ] Interactive runs append a gate acceptance line to build-log.md at each phase gate
- [ ] Continuous runs do not prompt at phase gates
- [ ] Resume detection reads `plan/.run-mode` to restore run mode
- [ ] `plan/.run-mode` is included in the P0 commit step

## Dependencies
- REQ-004 (P0 commit step must include plan/.run-mode)

## Input Validation

- [ ] Input source: filesystem read of `plan/.run-mode`
- [ ] Allowed character pattern: `continuous|interactive` — any other value treated as `interactive`
- [ ] Maximum length: 12 characters — content beyond this limit is treated as `interactive`
- [ ] Failure behaviour: on read error or empty result, default to `interactive` — do not halt
- [ ] Logging policy: sanitised value only; raw file content not separately logged
