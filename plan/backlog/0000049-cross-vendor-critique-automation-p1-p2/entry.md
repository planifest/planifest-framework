---
title: "Backlog Entry: 0000049 - Cross-vendor critique automation for P1/P2"
summary: "Automate cross-vendor critique for P1/P2 once per-project model-access configuration exists, revisited alongside same-vendor evidence."
status: "open"
---
# Backlog Entry: 0000049 - Cross-vendor critique automation for P1/P2

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** P6 (docs-agent `recommendations.md`, feature archived — backfilled retroactively by req-006)
**Deferral source:** deliberate scope decision
**Date filed:** 2026-08-08

---

## Problem

`0000016-pipeline-governance-and-loop-engineering`'s scope document deferred cross-vendor critique automation for P1/P2. See `plan/_archive/0000016-pipeline-governance-and-loop-engineering-2026-07-11/recommendations.md` ("Deferred Items" table): "Cross-vendor critique automation for P1/P2" was deferred with the note "Requires per-project model-access configuration; revisit alongside same-vendor evidence."

## Suggested Action

Revisit once per-project model-access configuration exists to support invoking a critique model from a different vendor than the authoring model, and once same-vendor critique evidence (REC-004 in the same `recommendations.md`, design-critic report-only precision on >=2 real features) has accumulated. Consult the original `0000016` scope document and ADRs for full rationale.

## Why Deferred

Blocked on infrastructure (per-project model-access configuration) that did not exist at the time, and on same-vendor evidence needed before cross-vendor automation is worth the added complexity — a deliberate scope decision recorded in the source feature's own scope document.
