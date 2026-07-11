---
title: "Requirement: REQ-001 - Backlog Folder Convention"
summary: "A durable plan/backlog/ home for discovered-but-out-of-scope work, filed by any phase agent."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-001 - Backlog Folder Convention

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-001
**Priority:** must-have
**Wave:** 0

---

## User Story

As any phase agent, I can file a discovered-but-out-of-scope item to `plan/backlog/{id}-{slug}/` instead of scope-creeping the active feature or looping back into shipped state, so that non-blocking findings aren't lost or forced into an immediate fix.

---

## Functional Requirements
- A `plan/backlog/` directory convention exists: one folder per deferred item, named `{id}-{slug}` where `{id}` is a zero-padded sequence number and `{slug}` is kebab-case
- A `backlog-entry.template.md` exists in `planifest-framework/templates/` capturing: problem statement, source feature-id and phase, date filed (ISO 8601), and suggested action
- The convention is documented in the orchestrator skill so every phase agent knows it may file an entry at any point without human pre-approval (filing is non-blocking; acting on it is human-gated at pickup)
- Filing an entry never modifies the active feature's scope, requirements, or design artifacts

## Acceptance Criteria
- [ ] `backlog-entry.template.md` exists and includes problem, source feature/phase, and date-filed fields
- [ ] The orchestrator skill documents the filing convention and its non-blocking nature
- [ ] A test fixture entry filed at `plan/backlog/0000001-example/` conforms to the template and triggers no gate-write block

## Dependencies
- None (foundational — REQ-002 consumes entries filed under this convention)
