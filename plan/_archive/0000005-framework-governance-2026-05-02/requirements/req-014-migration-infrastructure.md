---
title: "Requirement: REQ-014 - migration-infrastructure"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-014 - migration-infrastructure

**Feature:** 0000005-framework-governance
**Source:** migration infrastructure user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- `planifest-framework/migrations/` must exist as a directory; `planifest-framework/migrations/_done/` must exist as the archive subdirectory
- planifest-orchestrator SKILL.md must scan `planifest-framework/migrations/` at every session start for `.md` files not in `_done/`; if any are found, the orchestrator must invoke the `planifest-migrator` skill before proceeding with any other phase work
- `planifest-framework/skills/planifest-migrator/SKILL.md` must be created; its responsibilities: read the pending migration file, describe to the human what it will change, execute interactively asking the human to confirm each change or batch, move the migration file to `_done/` when complete or explicitly skipped
- A human may add a new migration by dropping a `.md` file into `planifest-framework/migrations/` — the orchestrator detects and triggers it on the next session start
- `planifest-framework/migrations/0001-date-format.md` must be created: scans `plan/`, `docs/`, and `planifest-framework/` for dates in document body text not matching DD MMM YYYY; presents each finding with file path, line number, current value, and proposed correction; applies confirmed changes; skips declined ones; reports summary; moves to `_done/` on completion
- `planifest-framework/migrations/0002-british-english.md` must be created: same scan/present/apply/archive pattern for American English prose spellings; must skip code identifiers (detected by file type and line context)

## Acceptance Criteria

- [ ] `migrations/` and `migrations/_done/` directories exist
- [ ] `planifest-migrator/SKILL.md` exists with interactive execution model
- [ ] Orchestrator scans migrations/ at session start before any other phase work
- [ ] `0001-date-format.md` migration exists and runs against this repo's existing artifacts
- [ ] `0002-british-english.md` migration exists; skips code identifiers correctly

## Dependencies

- REQ-013 (formatting-standards) — defines what these migrations are correcting toward
