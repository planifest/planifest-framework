---
title: "Requirement: REQ-014 - Migration Resumable with Progress File"
summary: "Migration tracks completed archives in a progress file; partial runs resume from last checkpoint."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-014 - Migration Resumable with Progress File

**Skill:** planifest-migrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- The migration (REQ-008) writes a progress file to `planifest-framework/migrations/_progress/{migration-name}.json` after each archive is processed
- Progress file records: list of completed archive paths, the human's confirmed adoption mode for each, and whether `docs/about.md` has been written
- On resume, the migration reads the progress file and skips already-completed archives
- If the progress file is absent, the migration starts from the beginning
- The progress file is deleted when the migration completes successfully (moved to `_done/` alongside the migration file)
- If `plan/_archive/` is empty or absent, Part A is skipped cleanly and Part B proceeds

## Acceptance Criteria
- [ ] Progress file written after each archive is processed
- [ ] Resumed migration skips archives listed in the progress file
- [ ] Progress file deleted on successful completion
- [ ] Empty or absent archive directory skips Part A cleanly with a log message
- [ ] Progress file schema includes: `completedArchives[]`, `aboutMdWritten` boolean

## Dependencies
- REQ-008 (migration that this tracks)
