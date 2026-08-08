---
title: "Backlog Entry: 0000069 - Keep resolve-phase endDedupFlag distinct from the shared getFlagPath"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000069 - Keep resolve-phase endDedupFlag distinct from the shared getFlagPath

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`planifest-framework/hooks/telemetry/resolve-phase.mjs` keeps a local `endDedupFlag()` that builds `phase-end-emitted-{session}-{phase}`, sitting directly beside the newly shared `hooks/telemetry/get-flag-path.mjs`, which builds `phase-start-{session}-{phase}`. The two look like the same helper and are not: different filename, different purpose (the resolver's own re-exec dedup versus the phase-start dedup flag), different lifecycle.

`0000028-req-002` ruled `endDedupFlag()` explicitly out of the extraction for that reason. The residual risk is a future reader merging them on the assumption that a shared `getFlagPath()` should own every flag path in the directory, which would break `phase_end` dedup and cause duplicate `phase_end` events.

## Suggested Action

Leave them separate. If a future feature ever does unify them, both filename shapes and both purposes must survive the merge, and `phase_end` dedup needs an explicit test proving a second `Stop` firing in the same session and phase emits nothing.

## Why Deferred

See `0000028`'s `tech-debt.md` TD-003. Not a defect and not scheduled work: this entry exists so the trap is on the record rather than resting on a code comment alone. `get-flag-path.mjs` carries a comment recording why the two are separate.
