---
title: "Scope - backlog-batch-governance-tooling-fixes"
summary: "Defines explicit boundaries of what is in scope and out of scope."
status: "active"
version: "0.1.0"
---
# Scope - backlog-batch-governance-tooling-fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Wave:** single wave (not waved)
**Version:** 0.27.0

## In Scope

- Wire `emit-phase-start.mjs`/`emit-phase-end.mjs` into `setup.sh`/`setup.ps1`'s hook-config writer, gated by the existing unified telemetry signal, with a positive-presence check (req-001).
- Fix `cline.sh`/`cline.ps1`'s boot-file/skills-dir path collision by relocating the boot file into `.clinerules/00-planifest-boot.md`, plus a regression test (req-002).
- Add explicit out-of-scope-discovery filing instruction (to `plan/backlog/`, not a host-tool mechanism) to `agent-dispatch-standards.md` and relevant phase-skill dispatch sections, with the dispatching agent pre-computing the next backlog ID (req-003).
- A deterministic backstop verifying `plan/.telemetry-failures/` is checked at every phase boundary and that agent-driven `emit_event` calls actually occurred — exact mechanism resolved by a P2 ADR (req-004).
- An explicit P0 step distinguishing a `planifest-framework/` dependency update from an arbitrary code push, requiring human confirmation of both the update and its provenance, documented as this repo's Framework Update Policy — exact mechanism resolved by a P2 ADR (req-005).
- One-time backfill of the 7 Deferred Items/Tech Debt rows found across 4 pre-0000025 archived features' `recommendations.md` into tagged `plan/backlog/` entries, never modifying the source files (req-006).
- An ADR recording the skill-scope-principle test with the four TDD-loop skills as worked examples (req-007, produced at P2).
- A named minimal default Phase 1 artifact set with explicit trigger conditions for cost model/SLOs/operational model, reflected in `feature-pipeline.md`, `planifest-spec-agent`, and the README's stated default artifact count (req-008).

## Out of Scope

- Backlog entries `0000040`/`0000041` referenced from `0000046`'s problem statement — not present in this repo's `plan/backlog/`, external to this run.
- Retroactively rewriting already-archived features' `recommendations.md` files beyond the one-time read-only backfill in req-006 (source files are never modified or deleted).
- Any remaining `plan/backlog/` entries not in this confirmed batch: `0000020`, `0000022`, `0000023`, `0000025`, `0000026`, `0000042` — left untouched for a future pickup.
- Building a full new "update agent" implementation beyond what req-005's P2 ADR decides — if the ADR chooses "new agent," only the scope that ADR defines is built, not a speculative superset.

## Deferred

- Nothing newly deferred at the feature level. Two items carry an internal P2 dependency (not a deferral): req-004's backstop mechanism and req-005's update-flow mechanism are both explicitly undecided pending their respective ADRs — implementation of each is blocked until its ADR lands, per `execution-plan.md`'s Open Questions.
