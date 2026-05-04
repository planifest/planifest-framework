---
title: "ADR 002: Sub-agent model tier — recommended_model frontmatter convention"
summary: "TDD sub-agents (test-writer, implementer, refactor) declare a preferred cheaper model tier via a recommended_model frontmatter field in their SKILL.md. This is an advisory convention: the invoking orchestrator should honour it, but there is no hard runtime enforcement."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - Sub-agent model tier — recommended_model frontmatter convention

**Feature:** 0000004-tdd-regression-test-quality
**Status:** accepted
**Date:** 2026-04-26

---

## Context

The TDD sub-loop (ADR-001) introduces 3 sub-agent invocations per requirement. On a feature with 10 requirements, this produces 30 sub-agent invocations. If each sub-agent runs at the same model tier as the orchestrating codegen-agent (e.g. Claude Sonnet), the token cost multiplies significantly relative to the current single-pass approach.

The three TDD sub-agents have narrow, well-defined tasks:
- test-writer: write one test file for one requirement
- implementer: write minimum code to pass one test
- refactor: improve existing code without adding behaviour

These tasks do not require the full reasoning capacity of the orchestrator model tier. A cheaper, faster model (e.g. claude-haiku) is well-suited to them.

The question is how to communicate the preferred model tier to the orchestrator in a way that is portable, inspectable, and consistent with the Planifest skill convention.

---

## Decision

Each TDD sub-agent SKILL.md MUST include a `recommended_model` field in its YAML frontmatter with value `haiku` (or equivalent cheaper tier for the active tool's model naming scheme). Example:

```yaml
---
name: planifest-test-writer
recommended_model: haiku
---
```

The orchestrating codegen-agent reads this field and SHOULD invoke the sub-agent at the recommended model tier when the tool supports per-invocation model override. The field is **advisory**: if the tool does not support model override, the sub-agent runs at the default tier — the pipeline is not blocked.

A rationale section in each SKILL.md explains why the cheaper tier is appropriate for that skill's task.

This approach was chosen because:
- It is declarative and co-located with the skill definition — no separate configuration file.
- It is inspectable: any agent or human reading the SKILL.md immediately sees the model intent.
- It is non-blocking: unsupported environments degrade gracefully (higher cost, same correctness).
- It establishes a reusable convention for future narrow sub-agent skills.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| **Hardcode model in codegen-agent SKILL.md** | Single place to update | Couples orchestrator to sub-agent model details; not co-located with sub-agent | Violates principle of co-locating skill configuration with the skill |
| **Separate model-config.json registry** | Centralised; easy to audit all model choices | Additional file to maintain; indirection makes it harder to read a skill in isolation | Overhead not justified for three skills; convention is simpler |
| **No model guidance — let operator decide** | Maximum flexibility | No default behaviour; operators must configure per invocation; higher default cost | Operators should not need to understand sub-agent model requirements to use the pipeline |
| **Hard enforcement via hook or runtime check** | Guaranteed cost control | Requires tool-specific enforcement code; blocks pipeline if not supported | Breaks the additive constraint; over-engineering for an advisory optimization |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-test-writer | Gains `recommended_model: haiku` frontmatter |
| planifest-implementer | Gains `recommended_model: haiku` frontmatter |
| planifest-refactor | Gains `recommended_model: haiku` frontmatter |
| planifest-codegen-agent | SKILL.md updated to read and honour `recommended_model` when invoking sub-agents |

---

## Consequences

**Positive:**
- Token cost for sub-agent invocations reduced by ~10–20× per invocation when supported.
- Convention is reusable: future narrow skills can adopt the same frontmatter pattern.
- Cost intent is inspectable in version control without additional tooling.

**Negative:**
- If tool does not support model override, cost benefit is not realised — the field is advisory only.
- `haiku` is Anthropic-specific naming; other tools may use different tier labels. The SKILL.md rationale section should describe the tier in capability terms (not just model name) to remain portable.

**Risks:**
- Agent SDK model override support varies. If unsupported, all sub-agents run at full model tier — cost mitigation is lost but correctness is unaffected.
- Future model naming changes (e.g. haiku → haiku-next) may require updating three SKILL.md files. Mitigation: use the most stable tier label available (e.g. `haiku` as a family name).

---

## Related ADRs

- ADR-001 — depends-on (sub-agents only exist because of the TDD inner loop decision)
