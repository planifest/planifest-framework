---
title: "Backlog Entry: 0000026 - Document the backlog ID sequence convention"
summary: "Nothing states that backlog IDs come from their own sequence independent of feature IDs, so an agent filing an entry has to infer the rule and collisions with feature IDs look like mistakes."
status: "open"
---
# Backlog Entry: 0000026 - Document the backlog ID sequence convention

**Source feature:** N/A — surfaced while filing backlog entries 0000014–0000025 (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31

---

## Problem

Backlog IDs are allocated from a sequence independent of feature IDs. Nothing says so.

Three places describe the convention and all three stop short of the rule that matters:

- `plan/_archive/0000016-pipeline-governance-and-loop-engineering-2026-07-11/requirements/req-001-backlog-folder.md` — the originating requirement — defines `{id}` as "a zero-padded sequence number", without stating which sequence.
- `planifest-framework/templates/backlog-entry.template.md:8` repeats "`{id}` zero-padded sequence".
- The orchestrator's P0 backlog-pickup step (`planifest-orchestrator/SKILL.md:420`) references entry folders as `{id}-{slug}/` and defers to the template.

The consequence is that backlog IDs collide with feature IDs on entirely unrelated subjects, and the collisions look like defects to anyone who has not inferred the rule:

| ID | Backlog entry | Archived feature |
|---|---|---|
| 0000011 | Local timestamp on human design confirmation | `setup-parity-and-consistency-2026-05-17` |
| 0000012 | Orchestrator context-window clear and compaction | `docs-restructure-commit-directives-2026-05-18` |
| 0000013 | Setup refresh skill preserving settings | `codegen-component-version-bump-2026-05-18` |
| 0000018 | Repository self-description check in CI | `telemetry-emission-consistency-2026-07-31` |

The sequence has real history independent of features: backlog IDs `0000001`, `0000002`, `0000005` and `0000011` are referenced across `plan/_archive/` and `plan/changelog/`, and `plan/_archive/backlog-triage-2026-07-11/` records a triage that consumed earlier entries. That history is also why scanning `plan/backlog/` alone understates the high-water mark — picked-up and discarded entries have left the directory but their IDs are spent.

This session had to infer the rule by inspection before allocating 0000014–0000025, and raised it with the human rather than guessing. A future agent with no memory of that exchange will face the same ambiguity, and the plausible wrong guess — continuing from the highest *feature* ID — silently corrupts the sequence.

## Suggested Action

State the rule where an agent will actually meet it: in `backlog-entry.template.md` and in the orchestrator's P0 backlog-pickup step. Specifically, that backlog IDs are allocated from their own monotonic sequence, independent of feature IDs; that collisions with feature IDs are expected and must not be "corrected"; and that the next ID is the highest ever allocated plus one, counting entries already picked up or discarded — not merely the highest currently present in `plan/backlog/`.

Consider persisting the last allocated ID in a small marker (for example `plan/backlog/.last-id`) so allocation is a read rather than an archive scan. Fold the same statement into `req-001-backlog-folder.md`'s successor if that convention is ever restated.

## Why Deferred

A convention and documentation gap surfaced while filing 0000014–0000025; non-blocking, and it changes no behaviour. Small enough to fold into any run that touches the template or the orchestrator's P0 section.

No `_reference/` folder here: unlike 0000014–0000025 this entry does not derive from the external framework review, and copying those documents in would add noise rather than context.
