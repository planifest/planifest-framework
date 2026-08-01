---
title: "Backlog Entry: 0000028 - orchestrator session markers not committed before PR is raised"
summary: "ship-agent P7 Steps 7-9 instruct deletion of plan/.orchestrator-active, plan/.orchestrator-ack, and plan/.run-mode, but the deletion is prose-only and was not included in the P7 archive commit for 0000020, so the merged PR carried stale 'active session' markers onto main."
status: "open"
---
# Backlog Entry: 0000028 - orchestrator session markers not committed before PR is raised

**Source feature:** 0000020-setup-refresh-skill
**Source phase:** post-ship, discovered on main after PR #45 merge
**Date filed:** 2026-08-01

---

## Problem

`planifest-ship-agent`'s P7 Archive section (Steps 7-9) instructs deletion of `plan/.orchestrator-active`, `plan/.orchestrator-ack`, and `plan/.run-mode` as part of archiving. For 0000020, commit `13ba609` ("plan(p7): archive 0000020-setup-refresh-skill") did the file move/rename but did not include these three deletions — they were only ever deleted locally, uncommitted, in a later session. Meanwhile PR #45 was raised and squash-merged from a branch state that still had all three files present with content pointing at the already-completed `0000020-setup-refresh-skill` feature.

Result: `main` at merge commit `90c0e4e` carried a stale `plan/.orchestrator-active` marker. Because `auto-trigger-orchestrator` only fires when that file is **absent**, any fresh session pulling `main` would have had orchestrator auto-trigger silently suppressed, on a repo where no pipeline was actually active. Caught by chance in a following session (git status showed uncommitted deletions of these three files on the feature branch, from a stale prior local cleanup) and fixed retroactively on `main` in commit `74f44ff`.

The instruction to delete these markers exists only as prose in `SKILL.md` — there is no hook or CI check enforcing that they're absent (or correctly committed) before a PR is raised.

## Suggested Action

Either:
1. Move the marker deletion earlier and make it atomic with the P7 archive commit (same `git commit` as the `plan/current/` → `plan/_archive/` move), so there's no window where the deletion can be forgotten, or
2. Add a P9 pre-flight check to `planifest-ship-agent` (or a hook) that fails/warns if `plan/.orchestrator-active`, `plan/.orchestrator-ack`, or `plan/.run-mode` are still tracked and non-empty at the point the PR is about to be raised.

Option 2 is the more durable fix since it catches the failure mode regardless of which step forgot the deletion.

## Why Deferred

Process/tooling gap in `planifest-ship-agent`, not part of any feature currently in flight; needs its own scoping (whether to fix via commit ordering, a new hook, or both) before implementation.
