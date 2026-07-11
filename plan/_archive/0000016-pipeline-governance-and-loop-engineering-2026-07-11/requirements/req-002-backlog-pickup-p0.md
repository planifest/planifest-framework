---
title: "Requirement: REQ-002 - Backlog Pickup at P0"
summary: "Orchestrator scans plan/backlog/ at P0 and offers each entry to the human, one at a time."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - Backlog Pickup at P0

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-002
**Priority:** must-have
**Wave:** 0

---

## User Story

As the orchestrator starting a new feature, I scan `plan/backlog/`, present each entry to the human one at a time, and ask whether to pull it into scope for this initiative, so that deferred work gets revisited instead of forgotten.

---

## Functional Requirements
- A new P0 Start Action scans `plan/backlog/` for entry folders; an absent or empty directory is not an error (first-run path)
- Each entry is presented one at a time using the recommend-then-confirm pattern; the human answers pull-in / leave / discard
- Pulled-in entries are folded into the new feature's brief/requirements and the backlog folder is deleted in the same commit; left entries remain untouched; discarded entries are deleted with a build-log note
- A malformed entry (missing source feature/phase attribution) is flagged for human cleanup at pickup, never silently ignored

## Acceptance Criteria
- [ ] P0 with a seeded backlog entry presents it and honours each of the three answers (pull-in / leave / discard)
- [ ] P0 with no `plan/backlog/` directory proceeds without error or prompt
- [ ] A seeded malformed entry is surfaced to the human rather than skipped

## Dependencies
- REQ-001 (entry convention and template)

## Input Validation
- [ ] Input source: filesystem read of `plan/backlog/{id}-{slug}/` folder names and entry file contents
- [ ] Allowed character pattern for folder names: `[a-zA-Z0-9\-]` — non-conforming folders are reported as malformed, not parsed
- [ ] Maximum length: 120 characters per folder name; entry body presented to the human is truncated at 2000 characters with a truncation note
- [ ] Failure behaviour: unreadable entry file → present as malformed with the path; do not halt P0
- [ ] Logging policy: only the sanitised folder name and truncated body appear in output
