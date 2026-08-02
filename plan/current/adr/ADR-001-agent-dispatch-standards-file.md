---
title: "ADR 001: Extract agent dispatch reference data into a standards file"
summary: "Relocates the Model Tier Decision Table and Parallelism Rules + Agent Dispatch Template out of the always-loaded orchestrator skill into a new standards file, cited on demand by the orchestrator, ship-agent, and codegen-agent."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Extract agent dispatch reference data into a standards file

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Component:** planifest-framework
**Date:** 2026-08-02

## Context

`planifest-framework/skills/planifest-orchestrator/SKILL.md` currently contains two blocks of pure reference data with no canonical home elsewhere: the Model Tier Decision Table (which task types map to which model tier, plus a tier-to-model mapping by tool) and the Parallelism Rules + Agent Dispatch Template (MUST/Cannot-parallelise tables and the concrete dispatch skeleton). This content is duplicated in `planifest-framework/skills/planifest-ship-agent/SKILL.md` (its own copy of the model tier table) and cited by `planifest-framework/skills/planifest-codegen-agent/SKILL.md` ("Follows the orchestrator's canonical Parallelism Directive"). Because the orchestrator is loaded in full every session, this reference data adds roughly 766 words to every session regardless of whether a phase needs it yet, and model-id staleness (for example `claude-sonnet-4-6`) has to be fixed in two places instead of one.

## Decision

Create a new standards file, `planifest-framework/standards/agent-dispatch-standards.md`, as the canonical home for both the Model Tier Decision Table and the Parallelism Rules + Agent Dispatch Template, relocated byte-for-byte (not reworded) from the orchestrator. The orchestrator, `planifest-ship-agent`, and `planifest-codegen-agent` each keep a one-line pointer to this file instead of restating or citing the orchestrator for it.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Leave the content in the orchestrator; delete ship-agent's duplicate copy and point ship-agent at the orchestrator instead | Smallest diff; removes one of the two duplicate copies | Content still loads in full every session even when not needed; codegen-agent's citation would still point at the orchestrator | Does not solve the "always-loaded" problem this feature exists to fix |
| Fold the content into an existing standards file, e.g. `telemetry-standards.md` or `testing-standards.md` | No new file to create or register | Topically unrelated (telemetry envelope vs model/parallelism dispatch mechanics); a reader looking for dispatch guidance would not think to check a telemetry standards file; dilutes that file's own scope | Rejected on discoverability and scope-clarity grounds |
| Create the new standards file but name it generically, e.g. `dispatch-standards.md` | Shorter filename | Ambiguous whether "dispatch" means agent spawning or CI/CD or build-pipeline dispatch | Considered acceptable; `agent-dispatch-standards.md` chosen instead for naming consistency with the repo's existing `{topic}-standards.md` convention (`telemetry-standards.md`, `testing-standards.md`, `build-target-standards.md`) and to disambiguate from the CI/CD sense of "dispatch" |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | New file `standards/agent-dispatch-standards.md` becomes the canonical home for the Model Tier Decision Table and the Parallelism Rules + Agent Dispatch Template. `skills/planifest-orchestrator/SKILL.md` has both blocks removed and replaced with a one-line pointer. `skills/planifest-ship-agent/SKILL.md` has its duplicate Model Tier Decision Table removed and replaced with a one-line pointer. `skills/planifest-codegen-agent/SKILL.md` has its citation of the orchestrator's Parallelism Directive replaced with a one-line pointer to the new standards file. |

## Consequences

**Positive:**
- The always-loaded orchestrator skill shrinks by roughly 766 words, reducing the fixed context cost of every session.
- Model-id and parallelism-rule maintenance happens in exactly one file instead of two-plus, removing the class of bug where ship-agent's copy drifts from the orchestrator's.

**Negative:**
- Any phase skill that needs this data now requires an explicit load-on-need step rather than having it inline already, adding one extra lookup to those code paths.
- A skill author who adds a new phase skill and forgets to add the pointer could silently lose access to the model-tier or parallelism guidance, with no enforcement mechanism catching the omission.

**Risks:**
- If the standards file is not loaded at the exact moment a subagent is about to be spawned, model-tier guidance could be skipped for that spawn, producing a dispatch that does not follow the intended tier or parallelism rules.

## Related ADRs

- none - first ADR of this feature

## Supersedes

- none

## Superseded By

- none
