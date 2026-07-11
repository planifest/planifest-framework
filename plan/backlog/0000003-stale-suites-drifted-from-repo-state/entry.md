---
title: "Backlog Entry: 0000003 - Test suites asserting stale repo state"
summary: "test-0000009 expects a getting-started.md that no longer exists; test-0000010 flags 279/372 external skill name-vs-directory mismatches from the skill-library import."
status: "open"
---
# Backlog Entry: 0000003 - Test suites asserting stale repo state

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** P9 (post-ship review)
**Date filed:** 2026-07-11

---

## Problem

Two suites fail against genuinely drifted repo state (not test plumbing):

1. `tests/test-0000009-rail-tightening.sh` (2 fails): asserts `getting-started.md` documents the presence-check hook and the `--strict-orchestrator` flag, but `planifest-framework/docs/getting-started.md` no longer exists (docs were restructured in feature 0000012). Either the documentation content was lost in the restructure (doc gap) or the test asserts a stale path (test gap) — needs a decision, then a one-line fix either way.
2. `tests/test-0000010-framework-quality-improvements.sh` (1 fail): REQ-003 name-normalisation check reports 279 of 372 external skill directories whose SKILL.md `name:` field mismatches the directory name. The mismatch count exploded when the full external skill library was imported (commit 7ecb6f2, "include external skills") without normalising names.

Both pre-date 0000016 (present at the branch base).

## Suggested Action

For (1): decide whether the presence-check/strict-orchestrator documentation belongs in the current three-file docs set (`pipeline-reference.md` most likely), restore it there, and repoint the test. For (2): either normalise the imported skill directory names / `name:` fields via a migration, or scope REQ-003's check to framework-authored skills and exclude `external-skills/`.

## Why Deferred

Pre-existing drift unrelated to 0000016; (2) touches 279 directories and deserves its own reviewed decision rather than a ship-window fix.
