---
title: "Requirement: req-005 - P0 Framework-Dependency-Update Flow"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-005 - P0 Framework-Dependency-Update Flow

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-006 (0000046)
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As the human on the loop, I want P0 to distinguish a `planifest-framework/` dependency update from an arbitrary code push, so that I explicitly confirm both the update and its provenance before it applies.

## Functional Requirements

- P0 MUST surface a detected `planifest-framework/` dependency-folder update as a distinct decision point, presented separately from ordinary feature-brief coaching questions — it MUST NOT be silently applied and MUST NOT be conflated with, or folded into, the normal backlog-pickup/coaching Q&A flow.
- The distinct decision point MUST require the human's explicit confirmation of two separate facts before the update is treated as accepted: (1) that a `planifest-framework/` folder update is in fact what is being applied (as opposed to an arbitrary, unrelated code push touching the same paths), and (2) the update's provenance — its source release, commit, or migration identifier — so the human is confirming a specific, named origin, not a blanket "yes, update it."
- This requirement defines WHAT must be true of the P0 flow (a distinct, human-confirmed checkpoint with provenance capture). It does NOT select the implementation mechanism — whether this is delivered by a new dedicated agent/skill or by extending `planifest-migrator` is explicitly out of scope for this requirement and is resolved by a P2 ADR (see Dependencies).
- The resulting mechanism, once implemented, MUST be documented as this repository's actual "Framework Update Policy" at a stable, referenceable path. This closes the gap where downstream backlog entries `0000040`/`0000041` already reference a "Framework Update Policy" by name with no canonical definition existing anywhere in this repo.
- The Framework Update Policy document MUST describe, at minimum: how a `planifest-framework/` dependency update is detected and distinguished from an arbitrary code push, what provenance information is required before confirmation, and where in the P0 flow this checkpoint occurs.
- This requirement does not decide whether `0000040`/`0000041` themselves are pulled into any future batch — it only ensures that when they (or any other future entry) reference "the Framework Update Policy," that reference resolves to a real, findable document.

## Acceptance Criteria

- [ ] A documented Framework Update Policy exists at a stable path in this repository, such that a reference to "the Framework Update Policy" (as already used, with no definition, by downstream backlog entries `0000040`/`0000041`) resolves to real content
- [ ] The P0 flow (orchestrator skill and/or its dispatch guidance) has an explicit step or section for detecting and confirming a `planifest-framework/` dependency update, distinct from ordinary feature-brief coaching questions
- [ ] The distinct P0 step requires the human to confirm both that the change is a framework-folder update (not an arbitrary push) and its specific provenance (source release/commit/migration identifier) before it is treated as accepted
- [ ] The Framework Update Policy document does not silently apply an update — every path through it terminates in an explicit human confirmation or an explicit rejection, never an implicit pass-through
- [ ] The mechanism choice (new agent vs. extending `planifest-migrator`) is NOT hard-coded into this requirement's acceptance criteria — it is left to the P2 ADR referenced in Dependencies

## Dependencies

- Depends on a P2 ADR resolving the open mechanism question: whether this flow is implemented as a new dedicated agent/skill, or as an extension of the existing `planifest-migrator` skill. This requirement states only what must be true of the resulting behavior; the ADR selects how it is built. Do not implement against a guessed mechanism ahead of that ADR.
- Depends on `planifest-migrator`'s existing skill definition as prior art/context for the ADR's decision, regardless of which way the ADR resolves.
- No dependency on the other 7 requirements in this feature; can be actioned independently, though the confirmed design's suggested (non-blocking) sequencing places this alongside `0000045` as framework-process items.
