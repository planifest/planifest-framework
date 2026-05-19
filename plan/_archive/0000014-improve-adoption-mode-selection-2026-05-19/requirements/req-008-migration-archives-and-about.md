---
title: "Requirement: REQ-008 - Migration: Fix Archived Design.md Adoption Modes and Init docs/about.md"
summary: "Migration file that corrects adoption mode in archives and initialises docs/about.md."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-008 - Migration: Fix Archived Design.md Adoption Modes and Init docs/about.md

**Skill:** planifest-migrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- A migration file is written to `planifest-framework/migrations/` following the Planifest migration format
- Part A: scan `plan/_archive/**/design.md` for the adoption mode field; auto-detect best-guess correct mode from context clues (feature name, problem statement, stack); present each to the human one at a time via `planifest-migrator` for confirm or override
- Part B: initialise `docs/about.md` — read version signals from archive history and `docs/about.md` if present; suggest the most recent version derivable from archive history; ask human to confirm; if version is ambiguous or unreadable, ask the human directly
- Migration is resumable: progress tracked in `planifest-framework/migrations/_progress/{migration-name}.json` (REQ-014)
- Migration follows the one-question-at-a-time principle (REQ-012) throughout

## Acceptance Criteria
- [ ] Migration file exists at `planifest-framework/migrations/` with correct frontmatter
- [ ] Part A presents each archive's adoption mode correction one at a time
- [ ] Part A auto-detects a best-guess mode and states its rationale before asking human to confirm
- [ ] Part B suggests a version derived from archive history and asks human to confirm
- [ ] Part B prompts directly if version is ambiguous
- [ ] Migration is resumable via progress file (REQ-014)

## Input Validation
- [ ] Input source: filesystem reads of `plan/_archive/**/design.md` adoption mode field
- [ ] Allowed character pattern: `[a-zA-Z\-]+` — mode values only
- [ ] Maximum length: 32 characters per field value
- [ ] Failure behaviour: if a design.md is unreadable, skip that archive and log the skip in the progress file
- [ ] Logging policy: each corrected archive logged in progress file with old value, new value, and human decision

## Dependencies
- REQ-014 (resumable migration with progress file)
- REQ-012 (one-question-at-a-time)
