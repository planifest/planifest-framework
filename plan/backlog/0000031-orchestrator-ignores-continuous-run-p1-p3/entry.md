---
title: "Backlog Entry: 0000031 - Orchestrator ignores continuous_run for P1-P3"
summary: "The Phase Invocation Table's P1, P2, and P3 rows hardcode 'No exception' on their STOP rule, overriding the general continuous_run rule in Phase Conventions and forcing a human gate at every phase up to Codegen regardless of the run mode the human chose at P0."
status: "open"
---
# Backlog Entry: 0000031 - Orchestrator ignores continuous_run for P1-P3

**Source feature:** N/A — reported directly by the human on the loop after 0000022 shipped
**Source phase:** N/A (filed ad-hoc via chat, post-ship)
**Date filed:** 2026-08-02

---

## Problem

`planifest-framework/skills/planifest-orchestrator/SKILL.md`'s Phase Conventions section states the general rule: "STOP (P1–P6): wait for human confirmation before proceeding to the next phase unless `continuous_run: true` was set at P0, or the phase states its own exception below."

The Phase Invocation Table (P1-P6) rows for P1, P2, and P3 each hardcode "No exception" on their STOP rule column, which overrides the general `continuous_run` rule and forces a mandatory human confirmation at every one of those three phases regardless of the run-mode setting confirmed at P0. Phases 4-6 correctly honor `continuous_run` — they only stop on a non-clean result (a failed check, a non-Low security finding, or drift found).

Net effect: a human who explicitly selects "continuous run" at P0 still gets interrupted three times (after P1, P2, and P3) before Codegen output is even validated, with no way to avoid it short of the orchestrator being edited.

This is a pre-existing behaviour, not introduced by feature 0000022 (orchestrator redundancy removal) — that feature consolidated the old per-phase P1-P6 sections into the current Phase Invocation Table but explicitly preserved existing gate semantics (zero behavioural change was that feature's mandate), carrying the "No exception" wording forward verbatim from the original per-phase STOP lines.

## Suggested Action

Change the P1, P2, and P3 rows' STOP rule to honour `continuous_run` like P4-P6 do, rather than hardcoding "No exception". If P1-P3 are considered higher-stakes gates that should always interrupt even under continuous run (e.g. because requirements and architecture decisions are harder to unwind than a validation or docs pass), that should be a deliberate ADR-recorded decision, not the accidental default — pick up this backlog item to make the choice explicit either way.

## Why Deferred

Filed post-ship, ad-hoc via chat; requires a scoped decision (behavioural change to the gate protocol) that should not be bundled into an unrelated feature.
