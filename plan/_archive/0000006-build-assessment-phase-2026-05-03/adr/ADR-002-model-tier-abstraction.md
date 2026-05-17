---
title: "ADR-002: Model routing via capability tiers, not model names"
status: "accepted"
date: "03 May 2026"
---
# ADR-002: Model routing via capability tiers, not model names

## Context

The orchestrator needs to make conscious model selection decisions when spawning subagents. Different tools use different model names (Claude Code: claude-haiku-4-5 / claude-sonnet-4-6; Cursor: gpt-4o-mini / gpt-4o; Codex: o1-mini / o1; etc.). Hardcoding model names in the skill would break portability.

## Decision

Define two abstract **capability tiers** — *primary* and *cheaper* — in the orchestrator decision table. Tiers are mapped to concrete model names at dispatch time for the active tool.

## Consequences

- **Portable across all supported tools**: the decision logic is tool-agnostic; only the tier-to-model mapping changes per tool
- **Single table to maintain**: adding a new tool requires only a new row in the tier-to-model mapping, not a rewrite of routing logic
- **Auditable**: the build log records which tier was used per agent; P8 can surface under-use of the cheaper tier
- **Trade-off**: the tier-to-model mapping must be kept current as tools release new models; stale mappings may route to outdated model names
- **Not enforced at runtime**: the orchestrator resolves tiers by instruction, not by a runtime constraint; an agent that ignores the table cannot be blocked
