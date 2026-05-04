---
title: "ADR 001: TDD inner loop orchestrated within codegen-agent"
summary: "The red-green-refactor TDD loop is implemented as a per-requirement sub-loop inside the existing codegen-agent phase (P3), not as a standalone pipeline phase. Three narrow sub-agents handle each TDD phase and are orchestrated by the codegen-agent."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - TDD inner loop orchestrated within codegen-agent

**Feature:** 0000004-tdd-regression-test-quality
**Status:** accepted
**Date:** 2026-04-26

---

## Context

The Planifest P3 codegen phase currently uses an all-at-once approach: tests and implementation are written together per requirement without a structured red-green-refactor discipline. The design calls for introducing TDD as a per-requirement sub-loop.

The question is where to place the TDD loop in the pipeline architecture. Options range from adding a new standalone pipeline phase, to restructuring P3 internally, to introducing the loop as sub-agents orchestrated by the existing codegen-agent.

The decision must:
- Not break existing pipelines (additive constraint from design.md)
- Preserve the codegen-agent's orchestration role (multi-component sequencing, deviation handling)
- Keep the loop scoped to a single requirement at a time (TDD discipline)
- Allow cheaper model tiers for the narrow sub-agents

---

## Decision

The TDD loop is implemented as an **inner loop protocol inside the codegen-agent** (P3), not as a new pipeline phase. For each requirement, the codegen-agent orchestrates three sub-agents in sequence:

1. `planifest-test-writer` — writes one failing test, confirms RED
2. `planifest-implementer` — writes minimum passing code, confirms GREEN
3. `planifest-refactor` — improves quality, confirms all GREEN

The codegen-agent retains full orchestration responsibility: it tracks the current requirement, manages sub-agent invocations, enforces the 3-attempt escalation limit, and synthesises the overall implementation. Sub-agents are narrow, focused, and stateless between requirements.

This approach was chosen because:
- It keeps the pipeline phase count stable — operators do not need to learn a new phase.
- The codegen-agent already has the orchestration machinery (multi-component sequencing, escalation, capability skill loading).
- Sub-agents' narrow scope is a natural fit for cheaper model tiers (see ADR-002).
- The protocol is additive — existing codegen-agent behaviour is extended, not replaced.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| **Standalone P3a phase (test-write) + P3b (implement) + P3c (refactor)** | Clearly delineated in pipeline; each phase has its own artefacts | Three new pipeline phases multiply orchestrator complexity; breaks session continuity between phases; operators must manage three phase transitions per requirement | Too heavyweight for a per-requirement micro-loop; pipeline phase overhead dwarfs the task |
| **Single TDD agent (one skill, all three phases internally)** | Fewer invocations; simpler orchestration | Cannot use different model tiers per phase; harder to scope narrowly; blends concerns | Cheaper model tier benefit requires separate sub-agent invocations; blending phases reduces discipline |
| **External TDD tooling (e.g. test runner with watch mode)** | Proven tooling; no new skill files needed | Not agent-native; no LLM reasoning in test/implement steps; does not integrate with capability skills or requirement traceability | Requires non-LLM tooling setup per stack; not portable across stacks |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-codegen-agent | SKILL.md gains TDD inner loop protocol section; no structural change to phase |
| planifest-test-writer | New skill; invoked by codegen-agent per requirement |
| planifest-implementer | New skill; invoked by codegen-agent per requirement |
| planifest-refactor | New skill; invoked by codegen-agent per requirement |

---

## Consequences

**Positive:**
- TDD discipline is enforced per requirement without adding pipeline phases.
- Sub-agents are narrow enough to use cheaper model tiers, reducing cost per loop.
- Codegen-agent retains orchestration context across the full feature, enabling cross-requirement coherence.
- Additive — existing codegen-agent users are unaffected if they do not invoke sub-agents.

**Negative:**
- Three sub-agent invocations per requirement multiplies invocation overhead (latency and token cost) compared to the current single-pass approach.
- Codegen-agent SKILL.md becomes more complex, increasing the chance of agent misinterpretation.

**Risks:**
- If the Agent SDK does not support nested sub-agent invocation from within a skill, the protocol cannot be executed. Mitigation: documented as risk R-004; advisory if not supported.
- Sub-agent coordination failure (test-writer produces untestable test) escalates to human after 3 attempts — the pipeline stalls rather than auto-skipping.

---

## Related ADRs

- ADR-002 — depends-on (model tier selection for sub-agents)
- ADR-003 — related-to (regression promotion criteria, which depend on tests produced by this loop)
