---
title: "Requirement: req-005 - Backlog unification for deferred items"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-005 - Backlog unification for deferred items

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source:** US-005
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want `recommendations.md`'s Deferred Items and Tech Debt tables routed into `plan/backlog/` tagged by source, so that deferred work is centrally discoverable.

## Functional Requirements
- `planifest-docs-agent`'s recommendations.md generation step writes each Deferred Items row and each Tech Debt row it produces as its own `plan/backlog/{id}-{slug}/entry.md`, following `backlog-entry.template.md`, in addition to the existing `recommendations.md` tables.
- Each backlog entry filed this way is tagged with the source feature ID and phase (the feature that produced the deferral) using the template's existing `Source feature` / `Source phase` fields.
- `backlog-entry.template.md` gains a field that distinguishes why the entry was deferred - at minimum: discovered mid-flight (today's only case), deliberate scope decision (rationale already captured in the source feature's `scope.md`/ADRs), or tech debt - so entries filed from `recommendations.md` are distinguishable from ad hoc backlog filings.
- A backlog entry filed from a Deferred Items or Tech Debt row points back at the originating feature's archived docs (e.g. its `scope.md`, ADRs, or `recommendations.md`) for full rationale rather than duplicating that rationale in the entry itself.
- `{id}` allocation for entries filed this way follows the existing backlog convention: highest `{id}` ever allocated (including picked-up and discarded entries) plus one - no separate numbering scheme for docs-agent-filed entries.
- This routing mechanism applies only to features archived after this fix ships. It does not retroactively create backlog entries for Deferred Items/Tech Debt rows already sitting in already-archived features' `recommendations.md` files.

## Acceptance Criteria
- [ ] For a feature archived after this fix ships, every row in that feature's `recommendations.md` Deferred Items table has a corresponding `plan/backlog/{id}-{slug}/entry.md` tagged with the source feature ID.
- [ ] For a feature archived after this fix ships, every row in that feature's `recommendations.md` Tech Debt table has a corresponding `plan/backlog/{id}-{slug}/entry.md` tagged with the source feature ID.
- [ ] `backlog-entry.template.md` includes a field distinguishing an entry's deferral source (discovered mid-flight / deliberate scope decision / tech debt).
- [ ] A backlog entry filed from `recommendations.md` references the source feature's own docs for rationale instead of re-deriving or duplicating it.
- [ ] A future P0 backlog-pickup pass that reads only `plan/backlog/` (never opening any archived feature's `recommendations.md`) surfaces deferred items and tech debt filed by features archived after this fix.
- [ ] No already-archived feature's `recommendations.md` (e.g. 0000016, 0000020, 0000022, 0000024) is modified or backfilled with new backlog entries by this feature.

## Dependencies
- `planifest-docs-agent/SKILL.md` - owns `recommendations.md` generation; must be updated to also write backlog entries for Deferred Items/Tech Debt rows.
- `planifest-framework/templates/backlog-entry.template.md` - needs the new deferral-source field.
- `planifest-framework/templates/recommendations.template.md` - may need updating so its Deferred Items/Tech Debt table rows reference the filed backlog entry ID.
- Whether `recommendations.md`'s Deferred Items/Tech Debt tables become thin pointers into the new backlog entries, or are retired outright, is an open design decision (per the originating backlog entry 0000038's own note) - resolved by `planifest-adr-agent` in P2, not decided here.
