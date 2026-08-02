---
title: "Backlog Entry: 0000036 - Expand subagent dispatch beyond P1/P3 for wall-clock speed"
summary: "This feature's own run parallelized well at P1 (4 requirement docs) and P3 (4 codegen implementations), but the orchestrator did several other independent, non-cross-referencing writes serially and inline — the two new P4 test files, and the three separate P6 living-doc edits — that fit the same 'MUST parallelise' pattern already used successfully elsewhere in the same run."
status: "open"
---
# Backlog Entry: 0000036 - Expand subagent dispatch beyond P1/P3 for wall-clock speed

**Source feature:** 0000023-framework-pipeline-fixes
**Source phase:** P9 (Ship), raised by the human on the loop
**Date filed:** 2026-08-02

---

## Problem

This feature's build report (`plan/_archive/0000023-framework-pipeline-fixes-2026-08-02/build-report.md`) confirms P1 and P3 correctly dispatched 4 independent subagents each in one parallel batch (requirement docs, then implementations). But several other steps in the same run were done by the orchestrator directly, in-band, one after another, despite being independent, non-cross-referencing work that fits the orchestrator's own "MUST parallelise" table (Parallelism Rules, `planifest-orchestrator/SKILL.md`) and the phase skills' own directives:

- **P4:** two new grep-based test files (`test-0000023-req-001-continuous-run-p1-p3.sh`, `test-0000023-req-002-marker-commit-lifecycle.sh`) were written by the orchestrator sequentially, one after the other, to close a coverage gap. They're independent files testing independent, non-cross-referencing SKILL.md sections — exactly the "Requirement files for independent features" / "Independent requirement files (no cross-references)" pattern the orchestrator already dispatches to parallel subagents at P1.
- **P6:** `docs/component-registry.md`, `docs/decisions-index.md`, and `docs/architecture-overview.md` were each edited serially by the orchestrator, one Edit call after another. `planifest-docs-agent/SKILL.md`'s own Parallelism Directive lists "Drift checks across independent areas (API endpoints, domain terms, data ownership)" as a MUST-parallelise case; per-file living-doc updates that don't reference each other's content are a similar shape.

None of this was wrong — the work was small enough in this particular run (2 short test files, 3 short doc edits) that serial execution was fast in absolute terms, and CLAUDE.md's own decomposition override includes an explicit escape hatch ("too small to justify subagent overhead, state the reason"). But the *pattern* — falling back to serial inline execution once past the phases (P1, P3) where parallel dispatch is most habitual — is worth examining across a run that has more independent small tasks, where the cumulative round-trip latency would matter more.

## Suggested Action

Audit a handful of past feature build-reports (this one plus others in `plan/_archive/`) for phases where multiple independent files were touched serially by the orchestrator rather than dispatched. If a real pattern emerges (not just this run's small-scale case), consider either: (a) lowering the bar in the orchestrator's Parallelism Rules for when dispatch is preferred over inline execution — e.g. "2+ independent file writes with no shared state" rather than only naming specific phase-level patterns — or (b) leaving the current judgment-call threshold as-is if most instances turn out to be genuinely too small to be worth the subagent dispatch overhead (per this feature's own recorded example). Either way, the ADR-recorded answer should include a concrete cost/benefit comparison (subagent dispatch overhead vs. round-trip latency saved) rather than a blanket "parallelize everything" directive.

## Why Deferred

Raised live during this feature's own P9, based on one run's evidence — needs a broader sample (multiple past `plan/_archive/*/build-report.md` files) before a policy change is warranted, and any change to the Parallelism Rules threshold is itself a governance decision that should go through its own P0/ADR rather than being bundled into an already-shipping feature.
