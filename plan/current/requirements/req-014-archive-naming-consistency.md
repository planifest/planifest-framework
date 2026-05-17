---
title: "Requirement: REQ-014 - Standardise archive directory name to plan/_archive/"
summary: "Skills, templates, and the on-disk plan/archive/ directory use the wrong name. setup.sh and setup.ps1 are correct (plan/_archive/). Everything else must be updated to match."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-014 - Standardise archive directory name to plan/_archive/

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** P0 audit — setup.sh line 920 and setup.ps1 line 824 correctly use plan/_archive/ in indexing ignore rules (underscore prefix sorts to top alphabetically). However all skills (planifest-orchestrator, planifest-ship-agent, planifest-build-assessment-agent), templates, and the actual on-disk plan/archive/ directory use plan/archive/ (no underscore). setup scripts are the source of truth.
**Priority:** must-have

---

## User Story
As a framework user, I want the archive directory consistently named plan/_archive/ across all skills, templates, and scripts so that it sorts to the top of directory listings and the indexing ignore rule actually matches the real directory.

## Functional Requirements
- The canonical archive path is `plan/_archive/` — the underscore prefix is intentional (sorts to top alphabetically in all file browsers and ls output)
- All skills must be updated to reference `plan/_archive/` instead of `plan/archive/`:
  - `planifest-framework/skills/planifest-orchestrator/SKILL.md`
  - `planifest-framework/skills/planifest-ship-agent/SKILL.md`
  - `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md`
- All templates referencing `plan/archive/` must be updated to `plan/_archive/`
- A migration instruction document `planifest-framework/migrations/0003-archive-dirname.md` must be created following the same pattern as `0001-date-format.md` and `0002-british-english.md`. It must instruct the migrator skill to:
  - Check for `plan/archive/` in the repo root
  - If `plan/archive/` exists and `plan/_archive/` does not: rename it
  - If `plan/_archive/` already exists: print "already correct — no changes needed" and complete
  - If both exist: warn the human and halt — do not merge or overwrite; ask for direction
  - After rename: confirm with the human before marking the migration done
  - Move itself to `planifest-framework/migrations/_done/0003-archive-dirname.md` when complete
- A shell migration script `planifest-framework/migrations/migrate-archive-dirname.sh` must be created for users who prefer to run the rename manually rather than via the migrator skill:
  - Same three-case logic as above
  - Is idempotent: safe to run multiple times
- A corresponding `planifest-framework/migrations/migrate-archive-dirname.ps1` must be produced for Windows users
- `setup.sh` and `setup.ps1` are already correct — do not modify them

## Acceptance Criteria
- [ ] `planifest-orchestrator/SKILL.md` contains no reference to `plan/archive/` — all occurrences read `plan/_archive/`
- [ ] `planifest-ship-agent/SKILL.md` contains no reference to `plan/archive/`
- [ ] `planifest-build-assessment-agent/SKILL.md` contains no reference to `plan/archive/`
- [ ] No template in `planifest-framework/templates/` references `plan/archive/`
- [ ] `planifest-framework/migrations/0003-archive-dirname.md` exists and follows the same structure as `0001-date-format.md`
- [ ] `planifest-framework/migrations/migrate-archive-dirname.sh` exists and is idempotent
- [ ] `planifest-framework/migrations/migrate-archive-dirname.ps1` exists and is idempotent
- [ ] After the migrator runs `0003-archive-dirname.md` on this repo, `plan/_archive/` exists and `plan/archive/` does not, and `0003-archive-dirname.md` is moved to `_done/`
- [ ] `grep -r 'plan/archive' planifest-framework/` returns zero results (excluding setup.sh, setup.ps1, and migration files which reference the old name for rename logic)

## Dependencies
- None — setup scripts are already correct and are not modified
