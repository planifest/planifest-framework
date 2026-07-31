---
title: "Backlog Entry: 0000022 - Add token accounting per phase"
summary: "duration_ms per phase already ships from feature 0000018; add the token half using the same optional-field pattern so the cost question becomes answerable."
status: "open"
---
# Backlog Entry: 0000022 - Add token accounting per phase

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-009 in the corrected recommendations

---

## Problem

Adopters ask what the framework costs. Half the answer now exists: `planifest-framework/hooks/telemetry/emit-phase-end.mjs:149-172` computes and emits `duration_ms` per phase, degrading silently when unconfigured — the right shape, landed in feature 0000018.

Token accounting is absent. Without it, the cost question has no answer and 0000023 cannot be run without collecting two of its four metrics by hand.

## Suggested Action

Emit token counts on `phase_end` where the host tool exposes them, using the same optional-field pattern already established for `duration_ms` — present when available, omitted otherwise, never blocking the pipeline. Absent instrumentation should degrade exactly as the duration path already does.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. Cheaper than originally scoped by the first-edition review, which treated duration and tokens as one unbuilt requirement — only the token half remains. Should precede 0000023, which consumes it.
