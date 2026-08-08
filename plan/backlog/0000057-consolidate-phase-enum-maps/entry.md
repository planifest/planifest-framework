---
title: "Backlog Entry: 0000057 - consolidate duplicated phase-enum maps"
summary: "check-telemetry-receipts.mjs's PHASE_NUMBER_TO_ENUM map duplicates resolve-phase.mjs's own PHASE_SKILLS map conceptually; follows this repo's existing per-hook-file-duplication precedent but could drift if one is edited without the other."
status: "open"
---
# Backlog Entry: 0000057 - consolidate duplicated phase-enum maps

**Source feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`planifest-framework/hooks/enforcement/check-telemetry-receipts.mjs`'s `PHASE_NUMBER_TO_ENUM` map (P1-P9 → spec/adr/codegen/.../ship) duplicates `planifest-framework/hooks/telemetry/resolve-phase.mjs`'s own `PHASE_SKILLS` map (phase-skill name → phase enum) conceptually — both encode the same phase taxonomy from different starting keys. This follows this repo's existing precedent of every hook file duplicating its own small helpers rather than sharing code (no components-shared-code convention exists yet), so it is not a deviation, but a future edit to one map without the other could silently drift the two out of sync. See TD-001 in `plan/current/recommendations.md` (feature 0000027).

## Suggested Action

Extract both maps to one shared source once this repo establishes a components-shared-code convention (e.g. a `hooks/telemetry/phase-enum.mjs` both files import). Not urgent — no functional bug exists today, both maps are small and static.

## Why Deferred

No components-shared-code convention exists in this repo yet to extract into; introducing one just for this pair of small maps would be disproportionate. Revisit once a second, unrelated need for shared hook code arises.
