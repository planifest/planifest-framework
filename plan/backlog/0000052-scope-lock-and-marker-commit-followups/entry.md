---
title: "Backlog Entry: 0000052 - Scope Lock drafts and marker-commit follow-ups"
summary: "0000022's P0 filed backlog 0000029 and 0000030 but implemented neither; flag both for the next P0 backlog pickup."
status: "open"
---
# Backlog Entry: 0000052 - Scope Lock drafts and marker-commit follow-ups

**Source feature:** 0000022-orchestrator-redundancy-removal
**Source phase:** P6 (docs-agent `recommendations.md`, feature archived — backfilled retroactively by req-006)
**Deferral source:** deliberate scope decision
**Date filed:** 2026-08-08

---

## Problem

`0000022-orchestrator-redundancy-removal`'s recommendations recorded a second Deferred Items row. See `plan/_archive/0000022-orchestrator-redundancy-removal-2026-08-02/recommendations.md` ("Deferred Items" table): "Backlog 0000029 (Scope Lock drafts always presented) and 0000030 (marker commit at creation)" — "Both filed during this feature's P0; neither implemented here" (When to Address: "Next P0 backlog pickup"). This references the pre-existing backlog entries `plan/backlog/0000029-scope-lock-drafts-always-presented/` and `plan/backlog/0000030-mandate-marker-commit-at-creation/` directly.

## Suggested Action

At the next P0 backlog pickup pass, check whether backlog entries `0000029` and `0000030` are still open (they were filed during `0000022`'s own P0 but not implemented within that feature) and consider picking them up together, since both surfaced from the same run.

## Why Deferred

Both items were discovered mid-flight during `0000022`'s P0 and deliberately scoped out of that feature's own delivery to keep it focused on redundancy removal; this row simply flags that neither had been actioned yet as of `0000022`'s close-out.
