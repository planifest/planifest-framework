---
title: "Requirement: req-006 - Backfill Historical Backlog"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-006 - Backfill Historical Backlog

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-005 (0000045)
**Priority:** could-have

## User Story

> One requirement doc = one user story.

As the human on the loop, I want deferred items and tech debt from pre-`0000025` `recommendations.md` files backfilled into `plan/backlog/`, so that a backlog-only pickup pass surfaces them too.

## Functional Requirements

- This is a ONE-TIME migration. It runs exactly once over the archived features that existed before `0000025` at the time this requirement is executed. It MUST NOT modify, rewrite, or delete any source `recommendations.md` file — every source file is read-only input to this migration.
- Verified by direct inspection of `plan/_archive/*/recommendations.md` (grep for `## Deferred Items` / `## Tech Debt` headings, not just the word "deferred" anywhere in the file), the pre-`0000025` archived features with an actual populated Deferred Items and/or Tech Debt table are:
  - `0000016-pipeline-governance-and-loop-engineering-2026-07-11` — Deferred Items table, 2 rows (`planifest-loop-designer` meta-skill; cross-vendor critique automation for P1/P2). No Tech Debt section.
  - `0000020-setup-refresh-skill-2026-08-01` — Deferred Items section present but explicitly states no items were deferred (0 rows, do not file a placeholder entry for it). Tech Debt table, 1 row (`TD-007`, `Write-SetupFlagsMarker` unverified by live `pwsh` execution).
  - `0000022-orchestrator-redundancy-removal-2026-08-02` — Deferred Items table, 2 rows (structural router decomposition per backlog `0000020`; backlog `0000029`/`0000030` follow-ups). Tech Debt section present but states no new tech debt was introduced (0 rows, do not file a placeholder entry for it).
  - `0000024-declared-product-id-for-telemetry-2026-08-03` — Deferred Items table, 1 row (Root Cause B from the `0000017` RCA re: missing `loop_iteration`/`phase_reversal_*` schema entries). Tech Debt table, 1 row (`TD-001`, duplicated `readProductId()` helper across telemetry hooks).
  - Total rows to file: 7 (2 + 1 + 2 + 2, counting only populated table rows, never the "no items" placeholder text as a row).
  - All other pre-`0000025` archived features with a `recommendations.md` (`0000001`, `0000003`, `0000007`, `0000009`, `0000011`, `0000012`, `0000013`, `0000017`, `0000018`, `0000019`, `0000021`, `0000023`) use headings other than `## Deferred Items`/`## Tech Debt` (e.g. "Recommendations", "Future Iterations", "Open Recommendations", "For a future pass") and are OUT OF SCOPE for this migration — they are not in the convention this requirement backfills against, and MUST NOT be included.
- Each of the 7 rows above MUST be filed as its own tagged `plan/backlog/{id}-{slug}/entry.md`, following `planifest-framework/templates/backlog-entry.template.md`, using the same convention `0000025`'s req-005 (`plan/_archive/0000025-.../requirements/req-005-backlog-unification.md`) established for docs-agent-filed entries going forward — this requirement performs the equivalent filing retroactively, once, for the pre-`0000025` history that convention explicitly excluded from its own scope.
- `{id}` for each new entry follows the existing Backlog ID sequence convention (see `planifest-orchestrator/SKILL.md`): the next ID is the highest ID ever allocated plus one, including spent/picked-up/discarded IDs, not just what is currently present in `plan/backlog/`. The highest ID referenced anywhere in this repo's `plan/` at the time this requirement was written is `0000047` (backlog entry folded into this same feature's P0); the migration MUST re-derive the true high-water mark at execution time (it may have moved) rather than hard-coding a number here, then allocate sequentially from there for all 7 entries.
- Each filed entry's `Source feature` field MUST be set to the originating archived feature's ID (e.g. `0000016`, `0000020`, `0000022`, or `0000024`), and `Source phase` MUST reflect that this was extracted from that feature's already-completed `recommendations.md` (post-P8 documentation), not a live in-flight phase.
- Each filed entry's `Deferral source` field MUST be set per the template's convention: rows originating from a Deferred Items table get `deliberate scope decision`; rows originating from a Tech Debt table get `tech debt`. Neither uses `discovered mid-flight` — that value is reserved for ad hoc live filings.
- Each filed entry's Problem/Suggested Action content MUST point back at the originating feature's `recommendations.md` (and, where the row itself references one, its underlying `scope.md`/ADR) for full rationale, rather than duplicating or re-deriving that rationale.
- This migration MUST NOT modify, annotate, or add cross-references into any already-archived `recommendations.md` file. The source files remain exactly as archived; only new files are created under `plan/backlog/`.
- This migration is distinct from, and does not depend on, `0000025`'s req-005 (which routes future `recommendations.md` output into the backlog automatically for features archived after that fix). This requirement covers only the historical, pre-`0000025` gap that mechanism explicitly left unaddressed.

## Acceptance Criteria

- [ ] Every pre-`0000025` `recommendations.md` Deferred Items/Tech Debt row identified above (7 rows across `0000016`, `0000020`, `0000022`, `0000024`) has a corresponding `plan/backlog/{id}-{slug}/entry.md`
- [ ] No entry is filed for a "no items were deferred" / "no new tech debt introduced" placeholder statement — only actual table rows are backfilled
- [ ] Each filed entry sets `Source feature` to the correct originating archived feature ID and `Deferral source` to `deliberate scope decision` (from Deferred Items) or `tech debt` (from Tech Debt), per row origin
- [ ] `{id}` allocation for all 7 entries is monotonic and starts from the true high-water mark at execution time (re-derived, not the `0000047` snapshot value in this doc, if it has since moved)
- [ ] No already-archived `recommendations.md` file (including but not limited to `0000016`, `0000020`, `0000022`, `0000024`) is modified, annotated, or deleted by this migration
- [ ] A future P0 backlog-pickup pass that reads only `plan/backlog/` (never opening any archived feature's `recommendations.md`) surfaces all 7 backfilled items

## Dependencies

- Depends on `planifest-framework/templates/backlog-entry.template.md` already carrying the `Deferral source` field (added by `0000025`'s req-005) — this requirement consumes that convention, it does not modify the template.
- References, but does not depend on or duplicate, `0000025`'s req-005 (`plan/_archive/0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes-2026-08-03/requirements/req-005-backlog-unification.md`), which explicitly scoped historical backfill out of its own delivery and left it for a future item — this requirement is that future item.
- No dependency on the other 7 requirements in this feature; can be actioned independently and in parallel with any of them.
