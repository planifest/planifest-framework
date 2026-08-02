---
title: "Backlog Entry: 0000038 - Unify deferred-item tracking into plan/backlog/ with a source field"
summary: "recommendations.md's Deferred Items and Tech Debt tables scatter deliberately-deferred scope calls across each feature's own archived docs with no central discoverability; route them into plan/backlog/ too, tagged by source, instead of splitting deferred-item tracking across two mechanisms."
status: "open"
---
# Backlog Entry: 0000038 - Unify deferred-item tracking into plan/backlog/ with a source field

**Source feature:** N/A - ad hoc observation, cross-checked against this repo's own `recommendations.template.md` / docs-agent output rather than a live pipeline run
**Source phase:** N/A - filed outside an active pipeline run
**Date filed:** 2026-08-02

---

## Problem

This framework currently has two separate places where "things not done now" get recorded:

1. `plan/backlog/{id}-{slug}/entry.md` - one file per item (`planifest-framework/templates/backlog-entry.template.md`), explicitly designed so a future P0 with no memory of the originating session can independently judge whether to pull it in. This is the location `planifest-orchestrator` and humans actually check when scoping new work.
2. The `## Deferred Items` and `## Tech Debt` tables in each feature's own `recommendations.md` (`planifest-framework/templates/recommendations.template.md`), produced per-feature and archived alongside it, e.g. `plan/_archive/0000022-orchestrator-redundancy-removal-2026-08-02/recommendations.md`, `plan/_archive/0000020-setup-refresh-skill-2026-08-01/recommendations.md`, `plan/_archive/0000016-pipeline-governance-and-loop-engineering-2026-07-11/recommendations.md`.

The rationale for the split is coherent in principle: backlog is for surprises found mid-flight that need independent future judgment; Deferred Items are deliberate scope calls already made during that feature's own P1/P2 design, with rationale already captured in that feature's `scope.md`/ADRs. But in practice this means there is no single inventory of "everything not yet done" - finding deliberately-deferred scope items or tech debt requires opening every archived feature's `recommendations.md` individually; nothing points a future triage pass at them the way `plan/backlog/` does. A future P0 (or a human scoping new work) that only checks `plan/backlog/` per the framework's own convention will silently miss every deliberately-deferred item sitting in an archived feature's tables instead.

## Suggested Action

Route Deferred Items and Tech Debt entries into `plan/backlog/` as well, using the existing `entry.md` template plus a new field distinguishing deferral source - e.g. "discovered mid-flight" (today's only backlog case) vs. "deliberate scope decision, rationale in `{feature}/scope.md`" vs. "tech debt" - so `plan/backlog/` becomes the single discoverable inventory regardless of why something was deferred, while each entry can still point back at the originating feature's archived docs for full rationale instead of duplicating it. As part of this, decide whether `recommendations.md`'s Deferred Items/Tech Debt tables become thin pointers into the corresponding backlog entries, or are retired in favor of filing directly to `plan/backlog/` from `planifest-docs-agent`/`planifest-ship-agent`.

This also settles the role split between the two artifacts once merged: `recommendations.md` stays a point-in-time snapshot, frozen at archive time as part of that feature's historical record - what was true and deliberately deferred when it shipped. `plan/backlog/` becomes the living document - status (`open`/picked-up/discarded) is expected to change after filing, as later features triage and act on entries. A `recommendations.md` pointer into a backlog entry can go stale (item picked up, status changed) without needing to be edited itself; the backlog entry is where current status actually lives.

## Why Deferred

Cross-cutting: touches `planifest-docs-agent` (writes `recommendations.md`), possibly `planifest-ship-agent`'s P7 archive step, and both templates (`recommendations.template.md`, `backlog-entry.template.md`) - affects every future feature's doc-generation step. Needs its own design decision (new field's exact schema, whether/how to backfill already-archived features' existing Deferred Items/Tech Debt tables) rather than a same-session tack-on.
