---
title: "ADR 004: Minimal default Phase 1 artifact set"
summary: "Names execution plan, requirements, scope, risk register, and domain glossary as the always-produced Phase 1 artifact set, with OpenAPI, cost model, SLO definitions, and operational model each gated by an explicit, checkable trigger condition."
status: "accepted"
version: "0.1.0"
---
# ADR-004 - Minimal default Phase 1 artifact set

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

Backlog `0000021` (this feature's req-008) reported that `planifest-framework/workflows/feature-pipeline.md`'s Phase 1 step mandates "execution plan, OpenAPI spec (if applicable), scope, risk register, domain glossary, operational model, SLO definitions, cost model" for every feature regardless of size — only the OpenAPI spec carries a condition. A trivial feature therefore produces a cost model and SLO definitions because the pipeline says so, not because anything about the feature warrants them, risking documentation theatre that causes reviewers to disengage — the review named this the main barrier to adoption by anyone who is not the framework's own author. This feature (`0000027`) already exercised the target judgment call at its own P0/P1: cost model, SLO definitions, and operational model were all marked N/A because the feature has zero deployed runtime footprint, and that determination is recorded in `plan/current/design.md`'s Architecture Layer and `plan/current/execution-plan.md`'s omitted sections — this ADR formalises that judgment call as a named, repeatable rule rather than a one-off exception.

## Decision

Name the minimal default Phase 1 artifact set, produced for every feature regardless of size: **execution plan, functional requirements (`plan/current/requirements/`), scope, risk register, domain glossary** — five artifacts. Every other Phase 1 artifact gets an explicit trigger condition, checkable from the confirmed design or feature brief:

| Artifact | Trigger condition |
|----------|-------------------|
| OpenAPI Specification | The feature's component acts as an API provider (already the existing condition — unchanged) |
| Operational Model | The feature introduces or modifies a deployed runtime service (a component with `data.ownsData: true` and a live compute/cloud target, or an explicit on-call/runbook need stated in the feature brief) |
| SLO Definitions | Same trigger as Operational Model — a deployed runtime service with a latency/availability/throughput target stated in the confirmed design's Architecture Layer |
| Cost Model | The feature introduces new compute, storage, third-party service spend, or materially changes existing spend (stated in the feature brief's NFRs or Constraints) |

Reflect this conditional set in both `planifest-framework/workflows/feature-pipeline.md` (replacing the current unconditional mandate) and `planifest-spec-agent/SKILL.md`'s own artifact table, so the workflow document and the agent that implements it agree. The orchestrator (via the spec-agent) produces only the minimal five absent a stated trigger; state the default artifact count (five, for a typical feature) in the project README.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Leave all artifacts unconditionally mandated | No process change needed | This is the exact problem being fixed — documentation theatre and reviewer disengagement, per the original review's finding | Directly contradicted by req-008's own problem statement |
| Make every artifact's production a human judgment call each time, no named triggers | Maximum flexibility | Reintroduces the same inconsistency this ADR exists to remove — different agents/humans would draw the line differently feature to feature | A named, checkable trigger is exactly what makes this "the workflow and the agent agree," per req-008's acceptance criteria |
| Drop Operational Model/SLO/Cost Model from the framework entirely, never produce them | Simplest possible default | Some features genuinely do need them (a new deployed service with real latency/availability targets) — removing them entirely would lose real governance value for those cases | The problem is unconditional mandate, not the artifacts' existence |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | `feature-pipeline.md`'s Phase 1 artifact list rewritten with explicit trigger conditions; `planifest-spec-agent/SKILL.md`'s artifact table updated to match; README gains a stated default artifact count |

## Consequences

**Positive:**
- Trivial features stop producing unwarranted cost/SLO/operational-model documentation, directly addressing the adoption barrier the original review identified.
- The trigger conditions are checkable from artifacts that already exist (confirmed design, feature brief) rather than requiring new judgment infrastructure.

**Negative:**
- A feature that's borderline (e.g. a component with `ownsData: true` but no explicit deployed-service claim) requires the orchestrator to make a judgment call at the trigger boundary rather than a purely mechanical check — mitigated by requiring that call to be stated and justified in the design, as this feature's own P0 did for its N/A determination.

**Risks:**
- A feature that skips an artifact under the new conditional rule, then later turns out to have needed it (e.g. a "no deployed service" feature quietly grows a compute dependency mid-pipeline), could ship without an operational model it should have had — mitigated by the existing Mid-Pipeline Requirement Change protocol, which already re-triggers earlier-phase artifacts when scope changes materially.

## Related ADRs

- None directly — this is the first ADR governing Phase 1 artifact scope.

## Supersedes

- None (the prior unconditional mandate in `feature-pipeline.md` was process prose, not a prior ADR)

## Superseded By

- None
