---
title: "Requirement: REQ-006 - Interrupted P9 Detection and Resume"
summary: "Orchestrator detects a partially-completed P9 on session resume and finishes cleanup before starting a new P0."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-006 - Interrupted P9 Detection and Resume

**Skill:** planifest-codegen-agent
**Feature:** 0000015-pipeline-session-cleanup
**Source:** US-001
**Priority:** must-have

---

## User Story

As a pipeline operator, I want each new feature to start with a completely clean session state, so that stale settings from a previous run never contaminate a new P0.

---

## Functional Requirements
- During resume detection, after checking `plan/current/` for artifacts, the orchestrator checks for interrupted P9:
  - **Signal:** `plan/.orchestrator-active` exists AND `plan/current/` is empty (no design.md, no requirements/, no adr/)
  - This combination indicates P9 archiving completed (plan/current/ cleared) but sentinel cleanup did not
- When interrupted P9 is detected:
  1. Open with: `P9: Resuming — interrupted cleanup detected. Completing P9 before starting new feature.`
  2. Delete `plan/.orchestrator-active`
  3. Delete `plan/.run-mode` if present
  4. Delete `plan/.orchestrator-ack` if present
  5. Confirm: `P9: Cleanup complete. Start a new session before beginning the next feature.`
  6. Stop — do not proceed to P0
- If `plan/current/` has artifacts AND `.orchestrator-active` exists: normal resume to the active phase (not interrupted P9)
- If neither condition matches: normal fresh start

## Acceptance Criteria
- [ ] Interrupted P9 (empty plan/current/ + .orchestrator-active present) produces the P9 resume message and completes cleanup
- [ ] Normal resume (plan/current/ has artifacts) is unaffected
- [ ] Fresh start (no .orchestrator-active) is unaffected
- [ ] After interrupted P9 cleanup, the orchestrator stops and does not begin P0
