---
title: "Requirement: req-002 - Marker Commit Lifecycle"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-002 - Marker Commit Lifecycle

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Source:** US-002
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want session markers committed at creation and reliably removed at archive time, so that a lost working tree or rushed PR never strands stale sentinel state on `main`.

## Functional Requirements

- In `planifest-framework/skills/planifest-orchestrator/SKILL.md`, Phase 0 Start Actions Step 1 ("Write the sentinel") MUST be updated to explicitly instruct committing `plan/.orchestrator-active` at the point it is written, matching the existing intent of the `.run-mode` pattern ("Include this file in the P0 commit.") elsewhere in the same file.
- In `planifest-framework/skills/planifest-orchestrator/SKILL.md`, Phase 0 Start Actions Step 5 ("Write strict-mode ack") MUST be updated to explicitly instruct committing `plan/.orchestrator-ack` at the point it is written, when this step is not skipped.
- In `planifest-framework/skills/planifest-ship-agent/SKILL.md`, P7 "Step 7 — Commit archive" MUST update its `git add` command to also stage the three marker paths deleted in Step 6, so their removal lands in the same commit as the archive move: `git add plan/_archive/ plan/changelog/ docs/about.md plan/.orchestrator-active plan/.orchestrator-ack plan/.run-mode`.
  - `git add` on an already-deleted tracked path stages the removal (same effect as `git rm`) — no special flag needed.
  - `git add` on a marker path that was never created this run (e.g. `.orchestrator-ack` when strict mode was not active) is a no-op warning, not a failure. Codegen must not add existence-checking logic around this — the plain `git add` invocation is sufficient and correct as-is.
- `planifest-framework/skills/planifest-ship-agent/SKILL.md` P9 MUST gain a pre-flight check, positioned before "Step 10 — Push/PR decision", that runs `git ls-files plan/.orchestrator-active plan/.orchestrator-ack plan/.run-mode` (or equivalent) and surfaces a clear warning to the human if any of the three paths are still tracked in git at that point. This is a durable backstop: if P7 Step 6/7 correctly removed and committed the markers, this check finds nothing; a hit means the atomic fix did not take, and the human must be told before a PR goes out with a stale marker on the branch.

## Acceptance Criteria
- [x] Phase 0 Start Actions Step 1 explicitly instructs committing `plan/.orchestrator-active` at write time — covered by `planifest-framework/tests/test-0000023-req-002-marker-commit-lifecycle.sh`
- [x] Phase 0 Start Actions Step 5 explicitly instructs committing `plan/.orchestrator-ack` at write time (when it is written) — same test
- [x] Ship-agent P7 Step 7's `git add` command includes all three marker paths (`plan/.orchestrator-active`, `plan/.orchestrator-ack`, `plan/.run-mode`) alongside the existing archive/changelog/about.md paths — same test
- [x] Ship-agent P9 has a pre-flight check (before the push/PR decision step) that verifies none of the three markers are still tracked in git, surfacing a clear warning if any are found — same test, "P9 pre-flight backstop check" section
- [x] This pipeline run (0000023) itself demonstrates the fix: its own P0-created markers (`.orchestrator-active`, `.run-mode`, and `.orchestrator-ack`, since strict mode is active in this repo) are committed at creation — already true as of this session's P0 commits, cited here as a dogfooding proof point

## Dependencies
- `planifest-framework/skills/planifest-orchestrator/SKILL.md` (Phase 0 Start Actions, Steps 1 and 5)
- `planifest-framework/skills/planifest-ship-agent/SKILL.md` (P7 Step 6/7, P9 pre-flight)
- No other component dependency; both parts touch only these two skill files.

## Background

This requirement merges two backlog items that are two ends of the same gap:

- **Creation side (backlog 0000030):** Phase 0 writes `plan/.orchestrator-active` (Step 1) and, when strict mode is active, `plan/.orchestrator-ack` (Step 5), but neither step instructs committing the file — unlike the existing, correct `.run-mode` pattern in the same file, which says: "Immediately after recording the answer, write `plan/.run-mode` containing either `continuous` or `interactive`. Include this file in the P0 commit."
- **Deletion side (backlog 0000028):** Ship-agent P7 Step 6 deletes the three markers from disk (sub-steps 5, 6, 7), but Step 7's `git add plan/_archive/ plan/changelog/ docs/about.md` never stages those deletions, since none of the three marker paths fall under those three prefixes. The deletions are therefore never committed. This is the confirmed root cause of backlog 0000028: a stale `plan/.orchestrator-active` landed on `main` after PR #45 merged (introduced at commit `90c0e4e`, fixed retroactively at commit `74f44ff`).

The fix has two layers: an atomic fix (stage all three marker paths in the same `git add` as the archive commit) and a durable backstop (a P9 pre-flight `git ls-files` check that catches any future regression of the atomic fix before a PR ships).
