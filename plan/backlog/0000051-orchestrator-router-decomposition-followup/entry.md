---
title: "Backlog Entry: 0000051 - Orchestrator structural router decomposition follow-up"
summary: "0000022 confirmed the dependency blocking backlog 0000020 (structural router decomposition of the orchestrator) is now resolved; pick it up."
status: "open"
---
# Backlog Entry: 0000051 - Orchestrator structural router decomposition follow-up

**Source feature:** 0000022-orchestrator-redundancy-removal
**Source phase:** P6 (docs-agent `recommendations.md`, feature archived — backfilled retroactively by req-006)
**Deferral source:** deliberate scope decision
**Date filed:** 2026-08-08

---

## Problem

`0000022-orchestrator-redundancy-removal`'s recommendations recorded a Deferred Items row confirming an existing backlog item is now unblocked. See `plan/_archive/0000022-orchestrator-redundancy-removal-2026-08-02/recommendations.md` ("Deferred Items" table): "Structural router decomposition of the orchestrator (backlog 0000020)" — "Pick up now - the dependency this feature was blocking on is resolved" (When to Address: "Next framework-maintenance feature"). This references the pre-existing backlog entry `plan/backlog/0000020-decompose-orchestrator-skill/` directly; `0000022`'s own REC-001 (same file) elaborates: `0000021`'s design.md had explicitly deferred `0000020` until the de-duplication pass in `0000022` landed, and that pass is now done (10,379 -> 8,592 words).

## Suggested Action

At the next framework-maintenance feature's P0, confirm backlog `0000020-decompose-orchestrator-skill` is still open and prioritize it — the blocking dependency this row describes is already satisfied, per `0000022`'s own recommendations.

## Why Deferred

Out of scope for `0000022` itself (that feature was a de-duplication pass, not the router decomposition); filed as a note that the previously-blocking dependency is now clear, for the next P0 pickup pass to act on against the existing `0000020` entry.
