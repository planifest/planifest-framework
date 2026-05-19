---
title: "ADR-006: Resumable Migration with Progress File"
summary: "Migration for adoption mode corrections and docs/about.md initialisation uses a JSON progress file for resumability rather than atomic all-or-nothing execution."
status: "accepted"
version: "0.1.0"
---
# ADR-006 - Resumable Migration with Progress File

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000014-improve-adoption-mode-selection
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-19

---

## Context

The adoption mode migration (REQ-008) is interactive: the human confirms each archive's adoption mode correction one at a time. A typical project may have 10–15 archived features. This migration will naturally span time and may span sessions. If the migration fails or is interrupted after processing 8 of 13 archives, the human should not have to repeat the 8 confirmed corrections from scratch.

Two strategies were considered: atomic (all archives corrected or none) and resumable (progress tracked, partial runs continue from last checkpoint).

---

## Decision

Use a **resumable progress file** at `planifest-framework/migrations/_progress/{migration-name}.json`.

The progress file records:
- `completedArchives`: array of archive paths already processed, with old value, new value, and human decision
- `aboutMdWritten`: boolean indicating whether `docs/about.md` has been initialised

On each resume, the migration reads the progress file and skips completed archives. The file is deleted on successful completion (moved to `_done/` alongside the migration file).

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Atomic (all-or-nothing, rollback on failure) | No partial state; clean success or clean failure | Discards all confirmed human decisions on failure; user must re-confirm everything | Unacceptable UX for an interactive, session-spanning migration |
| No progress tracking (restart from scratch) | Zero implementation complexity | Every session interruption restarts the entire migration | Same UX problem as atomic without the clean failure guarantee |
| Resumable with progress file | Preserves confirmed decisions; natural session boundary | Slightly more implementation complexity; progress file is a new artefact type | Chosen — best balance of resilience and simplicity |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-migrator skill | Reads and writes progress file during migration execution |
| planifest-framework/migrations/ | New `_progress/` subdirectory added |

---

## Consequences

**Positive:**
- Human confirmed decisions are preserved across session interruptions
- Migration can be run incrementally without time pressure
- Progress file provides an audit trail of what was changed and why

**Negative:**
- Progress file is a new artefact type that must be cleaned up on completion
- If the progress file becomes corrupted, the migration may skip archives or re-process them incorrectly

**Risks:**
- A bug in progress file write (e.g., partial write) could cause the migration to re-process an archive and overwrite a human-confirmed correction; mitigated by writing the full progress file atomically after each confirmation

---

## Related ADRs

- ADR-001 — related-to (migration exists to correct records from the old three-mode taxonomy)

---

## Supersedes

- None

## Superseded By

- None
