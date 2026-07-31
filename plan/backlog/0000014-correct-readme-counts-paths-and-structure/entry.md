---
title: "Backlog Entry: 0000014 - Correct README counts, paths and structure"
summary: "Five of seven framework-table rows misstate their counts, and the structure diagram names one path that does not exist and another that contradicts the framework's own CI — fix by removing the Count column and correcting both paths."
status: "open"
---
# Backlog Entry: 0000014 - Correct README counts, paths and structure

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-001 in the corrected recommendations; finding 3 in the corrected review

---

## Problem

Five of the seven rows in the `README.md` framework table misstate their counts, verified against the working tree at `f2162f7`:

| Row | Claimed | Actual | Line |
|---|---|---|---|
| `skills/` | 8 | 20 | `README.md:99` |
| `templates/` | 24 | 42 (39 `.md`) | `README.md:100` |
| `schemas/` | 2 | 2 — correct | `README.md:101` |
| `standards/` | 10 | 16 (14 `.md` + 2 dirs) | `README.md:102` |
| `setup/` | 14 | 18 | `README.md:103` |
| `hooks/` | 3 | 8 | `README.md:104` |
| `workflows/` | 4 | 4 — correct | `README.md:105` |

The `setup/` row is wrong twice over: it enumerates seven tools where nine adapters ship — `opencode` and `roo-code` are present but undocumented. `README.md:42` independently claims "orchestrator + 7 phase skills" against an actual twenty.

Two structural references in the repository-structure diagram are also wrong:

- `README.md:46` points to `planifest-framework/feature-structure.md` as the canonical directory layout. That file does not exist; it lives at `plan/feature-structure.md`.
- `README.md:55` shows a `planifest-docs/` directory where this repository has `docs/`. The framework's own CI and hooks encode `docs/` as canonical (`grep -qE "^(plan/|docs/|...)"`), so the diagram does not merely drift — it contradicts the enforcement. `README.md:144` separately and correctly describes `planifest-docs` as an external repository.

A specification-accuracy framework whose own specification is inaccurate undercuts the pitch in the first thirty seconds of a reader's attention.

## Suggested Action

Remove the Count column entirely rather than correcting the figures, and describe each folder by category instead of enumerating its members. Counts are a drift-generating construct with no reader value — the folder links already let a reader see the contents. Correct the two diagram paths so every path named resolves to something that exists, and align `README.md:42` and the `setup/` row so neither carries a member list that will drift again.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. Small enough to fold into a fast-path run alongside 0000015, 0000016 and 0000017, which touch the same files. Pairs with 0000018, which adds the CI check that stops this recurring.
