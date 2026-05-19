---
title: "Requirement: REQ-002 - Clear Run-Mode at P9"
summary: "Ship-agent deletes plan/.run-mode during P9 cleanup."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - Clear Run-Mode at P9

**Skill:** planifest-codegen-agent
**Feature:** 0000015-pipeline-session-cleanup
**Source:** US-001
**Priority:** must-have

---

## User Story

As a pipeline operator, I want each new feature to start with a completely clean session state, so that stale settings from a previous run never contaminate a new P0.

---

## Functional Requirements
- Ship-agent Step 6 (archive cleanup) deletes `plan/.run-mode` alongside `plan/.orchestrator-active` and `plan/.orchestrator-ack`
- Deletion is idempotent — if the file is already absent, no error is raised
- `plan/.run-mode` is included in the P7 commit's deletion set (staged as deleted)

## Acceptance Criteria
- [ ] After P9 completes, `plan/.run-mode` does not exist
- [ ] If `plan/.run-mode` was absent before P9 ran, no error is raised
