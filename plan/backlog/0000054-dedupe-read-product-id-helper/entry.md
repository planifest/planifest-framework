---
title: "Backlog Entry: 0000054 - Extract shared readProductId() helper if duplication becomes a burden"
summary: "TD-001: readProductId() is duplicated identically across 3 telemetry hooks, consistent with existing convention; extract a shared module only if duplication becomes a maintenance burden across all such helpers at once."
status: "open"
---
# Backlog Entry: 0000054 - Extract shared readProductId() helper if duplication becomes a burden

**Source feature:** 0000024-declared-product-id-for-telemetry
**Source phase:** P6 (docs-agent `recommendations.md`, feature archived — backfilled retroactively by req-006)
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`0000024-declared-product-id-for-telemetry`'s recommendations recorded tech debt item TD-001. See `plan/_archive/0000024-declared-product-id-for-telemetry-2026-08-03/recommendations.md` ("Tech Debt" table): `readProductId()` "is duplicated identically across all 3 telemetry hooks (`emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs`), consistent with this codebase's existing pattern of duplicating small helpers per file rather than a shared module." Impact if ignored: "None currently — matches established convention (`recordTelemetryFailure`, `readStdin` are duplicated the same way); a future shared-helper refactor would need to address all such duplicated functions together, not just this one."

## Suggested Action

If duplication ever becomes a maintenance burden across the 3 telemetry hook files, extract a shared `hooks/telemetry/_shared.mjs` module covering all duplicated helpers at once (`readProductId`, `recordTelemetryFailure`, `readStdin`), not just `readProductId` in isolation, per the source row's own suggested fix.

## Why Deferred

No impact currently — the duplication matches an established codebase convention rather than being an isolated defect, so extraction was deliberately left for a future pass that addresses all duplicated helpers together rather than one at a time.
