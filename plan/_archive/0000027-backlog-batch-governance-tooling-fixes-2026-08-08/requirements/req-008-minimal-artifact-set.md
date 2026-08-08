---
title: "Requirement: req-008 - Minimal Default Phase 1 Artifact Set"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-008 - Minimal Default Phase 1 Artifact Set

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-008 (0000021)
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a framework maintainer, I want a minimal default Phase 1 artifact set with explicit trigger conditions for the rest (cost model, SLOs, operational model), reflected consistently in `feature-pipeline.md` and `planifest-spec-agent`, so that trivial features stop producing documentation theatre that causes reviewers to disengage.

## Functional Requirements

- `feature-pipeline.md`'s Phase 1 step currently mandates a fixed, unconditional artifact list regardless of feature size. The exact current wording read at requirements time (step 3, "Phase 1 - Requirements"): "Produce: execution plan, OpenAPI spec (if applicable), scope, risk register, domain glossary, operational model, SLO definitions, cost model" — note that only the OpenAPI spec already carries a conditional ("if applicable"); operational model, SLO definitions, and cost model do not.
- Define the minimal default Phase 1 artifact set, always produced regardless of feature size: execution plan, functional requirements (`plan/current/requirements/`), scope, risk register, domain glossary. This is 5 artifact types (execution plan doc + requirements dir + scope + risk register + glossary), matching what this very feature (0000027) actually needed.
- Define explicit, checkable trigger conditions for each conditional artifact:
  - OpenAPI specification: triggered when "the component acts as an API provider" (this condition already exists in `planifest-spec-agent`'s SKILL.md and needs no change — cite as the existing pattern to extend to the other three).
  - Cost model: triggered when the feature "includes a deployed runtime service" or otherwise introduces new infrastructure, compute, storage, or third-party billed usage (a concrete, checkable property — not a subjective size judgment).
  - SLO definitions: triggered when the feature "includes a deployed runtime service" with a live traffic-serving surface (an API endpoint, a UI-served page, a background service with an uptime expectation).
  - Operational model: triggered when the feature "includes a deployed runtime service" requiring on-call/runbook coverage (i.e. something can page a human at 3am).
  - In practice cost model, SLOs, and operational model share one underlying trigger — "feature includes a deployed runtime service" — and should be evaluated together, not as three independently-judged conditions, per this feature's own P0 precedent (see Dependencies).
- The condition must be declared explicitly in the feature brief (e.g. a Target Architecture / Deployment line stating a new or changed deployed service) or, absent an explicit declaration, inferred from a stated property already present in the confirmed design (e.g. `design.md`'s Architecture Layer latency/availability targets being non-N/A). It must never be inferred from feature size or the number of user stories alone.
- Update `planifest-framework/workflows/feature-pipeline.md` Phase 1 step to list the minimal always-produced set plus the three conditional artifacts with their trigger conditions, replacing the current unconditional list quoted above. (Implementation of this update belongs to codegen, not to this requirement doc — this requirement specifies what the update must say.)
- Update `planifest-spec-agent`'s own SKILL.md artifact table/rules to state the same minimal set and the same trigger conditions, so the two documents cannot drift apart. Specifically, the "What You Produce" table's Operational Model, SLO Definitions, and Cost Model rows must each gain a stated trigger condition matching the OpenAPI row's existing "(if applicable)" pattern, with the actual condition spelled out rather than left implicit.
- The orchestrator (or spec-agent, when it runs Phase 1) must, absent a declared or inferred trigger, produce only the minimal 5-artifact set — it must not produce operational-model.md, slo-definitions.md, or cost-model.md as empty/N/A placeholder files. (This feature's own P0 handling — marking these three N/A in `design.md`'s Architecture Layer rather than generating placeholder P1 files for them — is the worked precedent this requirement generalizes; it does not need to be redone.)
- Update the project README to state the default artifact count for a typical (non-deployed-service) feature, so a reader can see up front how many artifacts to expect without a live-service trigger.

## Acceptance Criteria

- [ ] `feature-pipeline.md` and `planifest-spec-agent`'s own artifact list (SKILL.md "What You Produce" table) agree on the same conditional set: the same 5 always-produced artifacts, and the same trigger condition text for OpenAPI spec, cost model, SLO definitions, and operational model
- [ ] README states the default artifact count for a typical feature (5, absent a deployed-runtime-service trigger)
- [ ] Neither document mandates cost model, SLO definitions, or operational model unconditionally
- [ ] The trigger condition for cost model/SLOs/operational model is a concrete, checkable property (deployed runtime service) stated identically in both documents, not left as a vague size judgment

## Dependencies

- Worked precedent already exercised at P0 of this feature (0000027): `plan/current/design.md`'s Architecture Layer marks Latency target, Availability target, Scalability target, and Cost boundary as "N/A — no deployed runtime service," and the Assumptions section records this as "a judgment call per 0000021's own not-yet-shipped rule, confirmed with the human at P0." This requirement generalizes that judgment call into a standing, documented rule — it is not asking to redo or re-litigate that P0 decision.
- No dependency on the other 7 requirements in this feature; can be actioned independently and in parallel with any of them. Implementation touches `planifest-framework/workflows/feature-pipeline.md`, `.claude/skills/planifest-spec-agent/SKILL.md`, and `README.md` — three files, no shared mutable state, safe for a single codegen pass or parallel sub-dispatch per file.
