---
title: "Backlog Entry: 0000033 - ship-agent P7 Step 7 git add omits plan/current/"
summary: "planifest-ship-agent's P7 Step 7 'Commit archive' git add command never names plan/current/ explicitly; it only worked historically because git's rename detection happens to pick up the copy-then-delete as renames when plan/_archive/ is staged, which is incidental, not guaranteed."
status: "open"
---
# Backlog Entry: 0000033 - ship-agent P7 Step 7 git add omits plan/current/

**Source feature:** 0000023-framework-pipeline-fixes
**Source phase:** P7 (Archive), while live-executing the just-fixed req-002 marker-lifecycle commit
**Date filed:** 2026-08-02

---

## Problem

`planifest-framework/skills/planifest-ship-agent/SKILL.md`, P7 "Step 6 — Archive plan/current/" does a copy-then-delete: copies everything from `plan/current/` to `plan/_archive/{feature-id}-{date}/`, then deletes `plan/current/`'s contents. "Step 7 — Commit archive" then runs:

```
git add plan/_archive/ plan/changelog/ docs/about.md plan/.orchestrator-active plan/.orchestrator-ack plan/.run-mode
git commit -m "plan(p7): archive {feature-id}"
```

This command never names `plan/current/` — only the new `plan/_archive/` destination is staged. `git add <path>` only stages files *at* that path; it does not, by itself, stage the deletion of files elsewhere (`plan/current/...`).

In practice this has "worked" across prior features (verified directly: commit `4dba090`, the 0000022 archive commit) because `git add plan/_archive/` plus a separately-staged `plan/current/` deletion — which must have happened via some other means each time (broader judgment by the executing agent, or a `git add -A`/`.` at some point) — let git's similarity-based rename detection collapse the delete+add pairs into `R` (rename) entries in the resulting commit. That is incidental behavior of `git add`/`git diff` rename heuristics, not something the documented Step 7 command guarantees. If `plan/current/`'s deletion is never separately staged, the old files remain committed at their `plan/current/...` path *in addition to* the new archived copies — silently doubling the content and leaving stale `plan/current/` state on `main`, which is exactly the class of bug backlog 0000028 (and this feature's req-002) fixed for the three session markers specifically, but not for `plan/current/` itself.

Discovered while this feature's own P7 step live-executed the corrected Step 7 command (per req-002): the three markers staged correctly (explicitly named), but `plan/current/`'s ~19 files needed a separate, manual `git add plan/current/` before they'd stage as renames — confirmed necessary by checking `git status --short` showed them as unstaged `D` (deleted) entries even after the documented git add command ran.

## Suggested Action

Add `plan/current/` explicitly to Step 7's `git add` command, e.g.:

```
git add plan/_archive/ plan/changelog/ docs/about.md plan/current/ plan/.orchestrator-active plan/.orchestrator-ack plan/.run-mode
```

Consider whether this should be folded into the same fix pass as this feature's req-002 (marker commit lifecycle) rather than treated as fully separate, since it's the same Step 7 command and the same class of "deletion never explicitly staged" bug — just for `plan/current/` instead of the three markers.

## Why Deferred

Discovered mid-execution of an already-active P7 step in this feature's own pipeline run, not part of req-002's original scope (which only covered the three marker files by name, per its own requirement doc). Worked around live for this run's own archive commit (`git add plan/current/` added manually, verified via `git log --stat` against the 0000022 precedent commit) rather than editing `planifest-ship-agent/SKILL.md` again mid-P7 of the very feature that already edited it once this run — a second self-edit of the file governing the phase currently executing warranted its own scoped pickup rather than a rushed in-flight second change.
