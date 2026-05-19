---
title: "Requirement: REQ-003 - Stale Run-Mode Check at P0"
summary: "Orchestrator detects and clears stale plan/.run-mode at P0 pre-flight."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - Stale Run-Mode Check at P0

**Skill:** planifest-codegen-agent
**Feature:** 0000015-pipeline-session-cleanup
**Source:** US-001
**Priority:** must-have

---

## User Story

As a pipeline operator, I want each new feature to start with a completely clean session state, so that stale settings from a previous run never contaminate a new P0.

---

## Functional Requirements
- During P0 pre-flight (Step 0), after the branch check and before writing the sentinel, the orchestrator checks whether `plan/.run-mode` exists
- If `plan/.run-mode` exists at P0 start, the orchestrator:
  1. Surfaces a warning to the human: "⚠ Stale run-mode detected from a previous session (`{value}`). Clearing before proceeding."
  2. Deletes the file
  3. Continues P0 — does not block or halt
- If `plan/.run-mode` is absent, the check passes silently

## Acceptance Criteria
- [ ] Starting a fresh P0 when `plan/.run-mode` exists produces a visible warning and clears the file
- [ ] Starting a fresh P0 when `plan/.run-mode` is absent produces no output from this check
- [ ] P0 proceeds normally in both cases — the check is never a hard block

## Input Validation
- [ ] Input source: filesystem read of `plan/.run-mode`
- [ ] Allowed character pattern: `[a-zA-Z]` — only `continuous` or `interactive` are valid values; display the raw value in the warning (max 20 chars, truncate beyond)
- [ ] Maximum length: 20 characters — content beyond this is truncated in the warning message
- [ ] Failure behaviour: on read error, treat as absent — continue silently
- [ ] Logging policy: raw value shown in warning message only; not injected into model context
