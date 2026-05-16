---
title: "Requirement: REQ-002 - agent-tool-and-parallelism"
summary: "Add Agent to allowedTools in setup scripts; add Agent dispatch template and parallelism directives to orchestrator, codegen-agent, and validate-agent SKILL.md files."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - agent-tool-and-parallelism

**Skill:** planifest-spec-agent
**Feature:** 0000010-framework-quality-improvements
**Source:** P8 build report findings: Agent tool never invoked (0/8 phases); P3 and P4 ran sequentially despite parallelism directives existing.
**Priority:** must-have

> Written by the spec-agent. This file contains the requirements for a single feature so that agents can build it without loading the entire project scope.

---

## Functional Requirements

### setup.sh / setup.ps1

- When configuring for Claude Code (`claude-code` target), `setup.sh` MUST write an `allowedTools` array containing `"Agent"` into the project `.claude/settings.json`, merged with any existing `allowedTools` entries (not replaced)
- `setup.ps1` MUST apply the same logic for the Claude Code target
- The addition MUST be idempotent — running setup twice does not duplicate the entry

### planifest-orchestrator/SKILL.md

- MUST add an `## Agent Dispatch Template` section under the existing Parallelism Rules section
- The template MUST show a concrete example of a parallel Agent dispatch: two `Agent(...)` calls in a single message, with a filled-in `description`, `prompt` (self-contained, including file paths and context), and `subagent_type`
- The template MUST include the rule: "The prompt passed to Agent MUST be self-contained — include the requirement file path, relevant ADR paths, stack declaration, and any constraint the subagent needs. Do not rely on shared context."
- MUST add a note clarifying the two levels of parallelism: (1) parallel native tool calls within the orchestrator's own context (Write, ctx_execute, etc.) and (2) parallel Agent spawning for decomposed phase work — both are required; neither substitutes for the other

### planifest-codegen-agent/SKILL.md

- MUST add a `## Parallel Dispatch Checklist` section that runs before implementation begins
- The checklist MUST instruct the agent to: list all requirements for this phase, group them by dependency (leaf vs. dependent), dispatch all leaf requirements as parallel Agent calls in a single message before building dependents
- MUST include a worked example showing two requirements dispatched in parallel with concrete Agent call syntax

### planifest-validate-agent/SKILL.md

- MUST add a `## Pre-Execution Parallelism Plan` step before the CI check execution section
- The step MUST instruct: "Before running any check, list all checks required. Identify which are independent. Dispatch all independent checks in a single parallel batch (multiple Bash/ctx_execute calls in one message). Do not run sequentially without a stated dependency reason."

## Acceptance Criteria

- [ ] `setup.sh` writes `"Agent"` to `allowedTools` in project settings.json for Claude Code target
- [ ] `setup.ps1` does the same for Claude Code target
- [ ] Running setup twice does not add duplicate `"Agent"` entries
- [ ] `planifest-framework/skills/planifest-orchestrator/SKILL.md` contains `## Agent Dispatch Template` section with a concrete two-Agent parallel dispatch example
- [ ] The orchestrator dispatch template includes the self-contained prompt rule
- [ ] The orchestrator section clarifies the two levels of parallelism (native tool calls vs. Agent spawning)
- [ ] `planifest-framework/skills/planifest-codegen-agent/SKILL.md` contains `## Parallel Dispatch Checklist` with concrete Agent call syntax
- [ ] `planifest-framework/skills/planifest-validate-agent/SKILL.md` contains `## Pre-Execution Parallelism Plan` step before CI execution

## Dependencies

- None — SKILL.md changes are independent of each other; setup script changes are independent of SKILL.md changes
