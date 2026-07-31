---
title: "Backlog Entry: {{id}} - {{short-title}}"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: {{id}} - {{short-title}}

> Path: `plan/backlog/{id}-{slug}/entry.md` — one folder per entry, `{id}` zero-padded sequence, `{slug}` kebab-case.
> Any phase agent may file an entry at any time. Filing is non-blocking and never
> modifies the active feature's scope. Acting on an entry is human-gated at the
> next feature's P0 pickup (pull-in / leave / discard).
>
> **`{id}` is its own sequence, independent of feature IDs.** A collision between
> a backlog ID and an unrelated feature ID (e.g. `0000019-some-backlog-entry` and
> `0000019-some-feature`) is expected, not a defect — do not "correct" it. The next
> `{id}` to allocate is the highest ever allocated plus one, counting entries
> already picked up or discarded, not merely the highest ID currently present in
> `plan/backlog/` — picked-up and discarded entries leave the directory but their
> IDs stay spent.

**Source feature:** {{feature-id that discovered this}}
**Source phase:** {{P0–P9 phase active when discovered}}
**Date filed:** {{ISO-8601 date}}

---

## Problem

{{What was discovered. Specific enough that a future P0 — with no memory of this
session — can judge whether to pull it in. Name files/paths where relevant.}}

## Suggested Action

{{One or two sentences: what fixing it would look like. A suggestion, not a spec —
scope is decided at pickup.}}

## Why Deferred

{{Why this was not folded into the active feature: out of scope / non-blocking /
would need its own design decision.}}
