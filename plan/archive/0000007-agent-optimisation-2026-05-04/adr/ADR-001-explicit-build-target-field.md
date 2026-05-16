---
title: "ADR-001 - Explicit Build target field over stack inference"
status: "accepted"
date: "04 May 2026"
feature: "0000007-agent-optimisation"
---
# ADR-001 — Explicit Build target field over stack inference

## Context

When a project builds in Docker, agents were checking host-installed runtimes (e.g. `dotnet`, `node`, `python`) during code generation and validation. This produces irrelevant or misleading results. The stack declaration already includes `compute` and `iac` fields that imply Docker, so the question was whether agents should infer the build target from those fields or whether humans should declare it explicitly.

## Decision

Add an explicit `Build target: local | docker | ci-only` row to the feature-brief stack table. Agents read this field directly rather than inferring from `compute` or `iac`.

## Alternatives Considered

| Option | Pros | Cons | Rejected because |
|--------|------|------|-----------------|
| Infer from `compute: docker` or `iac: dockerfile` | No new field; reuses existing data | Inference is ambiguous — `iac: dockerfile` doesn't always mean build-in-docker; `compute: docker` may mean deployment target not build target; inference logic would need to live in every agent | Too error-prone; different agents may infer differently |
| Explicit `Build target` field (chosen) | Unambiguous; single source of truth; agent just reads it | Requires human to fill in an extra field | Precision justifies the extra field |
| Derive from CI platform field | Works when CI = docker | Doesn't cover local docker builds; CI field describes the CI system not the build environment | Too narrow |

## Affected Components

- `planifest-framework/templates/feature-brief.template.md` — new row added
- `planifest-framework/standards/build-target-standards.md` — defines all three tiers
- `planifest-orchestrator/SKILL.md` — coaches human to set field at P0
- `planifest-codegen-agent/SKILL.md` — reads field and adjusts behaviour
- `planifest-validate-agent/SKILL.md` — reads field and adjusts behaviour

## Consequences

**Positive:**
- Agent behaviour is deterministic — no inference ambiguity
- New tiers (`ci-only`) can be added to the standard without changing any inference logic
- Orchestrator can coach the human to set it when it detects Docker-related stack choices

**Negative:**
- Humans must fill in one more field in the feature brief
- Existing feature briefs do not have the field — retrofit briefs may default to `local` implicitly

**Risks:**
- Humans may leave the field at the default (`local`) even when building in Docker — mitigated by orchestrator P0 coaching

## Related ADRs

- None
