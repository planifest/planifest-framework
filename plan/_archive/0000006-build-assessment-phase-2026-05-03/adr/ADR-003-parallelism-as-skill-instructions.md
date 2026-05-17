---
title: "ADR-003: Parallelism enforced via skill instructions, not hooks"
status: "accepted"
date: "03 May 2026"
---
# ADR-003: Parallelism enforced via skill instructions, not hooks

## Context

The pipeline under-parallelises independent tasks. Options to enforce parallelism:
1. Skill instructions with explicit MUST directives
2. A PreToolUse hook that detects sequential tool calls and injects a warning
3. A new orchestrator validation step that audits the previous phase's tool call log

## Decision

Enforce parallelism via **MUST directives in skill files**. Each affected skill gets a visible "Parallelism Directive" section.

## Consequences

- **Zero new infrastructure**: no new hooks, no new MCP tools, no changes to setup scripts
- **Immediately portable**: all tools that read SKILL.md benefit without per-tool changes
- **Self-documenting**: the directive is visible to anyone reading the skill, not hidden in hook logic
- **Auditable via P8**: the build log records parallel task counts per phase; P8 flags phases where count was 0 when it should have been >0
- **Trade-off**: instruction-based enforcement relies on the model following the directive; a model that ignores it cannot be blocked. Hook-based enforcement would be deterministic but requires per-tool hook APIs and would only work for tools with PreToolUse hooks (currently only Claude Code and Copilot)
