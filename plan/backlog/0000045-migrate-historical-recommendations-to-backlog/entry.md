---
title: "Backlog Entry: 0000045 - Migrate historical recommendations.md deferred items to plan/backlog/"
summary: "req-005's backlog-unification routing (feature 0000025) is forward-only — deferred items/tech debt from recommendations.md files in features archived before 0000025 stay scattered in their own archived docs, not backfilled."
status: "open"
---
# Backlog Entry: 0000045 - Migrate historical recommendations.md deferred items to plan/backlog/

**Source feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source phase:** P6

**Date filed:** 2026-08-03

---

## Problem

Feature 0000025 (req-005) made `planifest-docs-agent` file each `recommendations.md` Deferred Items/Tech Debt row as its own `plan/backlog/{id}-{slug}/entry.md`, going forward only. Deferred items and tech debt recorded in `recommendations.md` files for features archived *before* 0000025 (e.g. `plan/_archive/0000016-.../recommendations.md`, `0000020-.../recommendations.md`, `0000022-.../recommendations.md`, `0000024-.../recommendations.md`) remain only in their own archived location — a future P0 backlog-pickup pass that reads only `plan/backlog/` will not surface them.

## Suggested Action

File a one-time migration feature (or Fast Path, if criteria are met) that walks every `plan/_archive/*/recommendations.md`, extracts each Deferred Items and Tech Debt row, and files it as a tagged `plan/backlog/{id}-{slug}/entry.md` per the same convention req-005 established — `Source feature`/`Source phase` set to the originating archived feature, `Deferral source` set appropriately.

## Why Deferred

Explicitly out of scope for 0000025's own req-005 (its acceptance criteria state "no already-archived feature's `recommendations.md` is modified or backfilled by this feature") and for the feature-brief's Out of Scope section ("Retroactively rewriting already-archived features' recommendations.md files to backfill the backlog-unification pattern"). Non-blocking — old items remain independently findable in their archived location; address only if operators report friction discovering them, not as a default follow-up.
