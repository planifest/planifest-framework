---
title: "Requirement: req-004 - model routing decision rules"
status: "active"
version: "0.1.0"
---
# Requirement: req-004 - model routing decision rules

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** "we'd expect complex work to use better models but everyday coding could be done by basic ones. there needs to be a conscious decision made by the orchestrator to spin up an agent with the appropriate model."
**Priority:** must-have

---

## Functional Requirements
- The orchestrator skill MUST contain an explicit **Model Tier Decision Table** that the orchestrator consults before spawning any subagent
- The decision table MUST define two tiers (not hardcoded model names — tiers are resolved to model names by the tool):
  - **Primary tier**: tasks requiring synthesis, multi-file reasoning, code generation, security analysis, architectural decisions
  - **Cheaper tier**: tasks requiring search/grep, single-file reads with no synthesis, formatting checks, simple file existence checks
- The decision table MUST include at least the following task classifications:
  - Codebase discovery (grep, find, ls) → cheaper tier
  - Web research with synthesis → primary tier
  - Web research — fetching a single known doc → cheaper tier
  - Code generation → primary tier
  - Security review → primary tier
  - Validation (lint/type checks) → cheaper tier
  - Formatting/spelling checks → cheaper tier
  - ADR writing → primary tier
  - Spec writing → primary tier
  - Documentation writing → cheaper tier (no novel decisions)
- The orchestrator MUST pass the resolved model to each spawned subagent (via the `model` parameter of the Agent tool, or equivalent for the active tool)
- The build log MUST record the tier used for each spawned agent so P8 can report on it
- Rules MUST be expressed in terms of task characteristics, not model names, so they apply across all supported tools

## Acceptance Criteria
- [ ] Orchestrator SKILL.md contains a "Model Tier Decision Table" section
- [ ] Table defines "Primary tier" and "Cheaper tier" task categories
- [ ] At least 8 task types are classified in the table
- [ ] Instruction present: resolve tier to model name for the active tool before spawning
- [ ] Instruction present: record tier in build-log.md for each spawned agent

## Dependencies
- req-001 (build-log must exist to record tier usage)
