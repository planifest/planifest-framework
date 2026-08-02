---
title: "Requirement: req-003 - class-2-relocations"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-003 - class-2-relocations

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Source:** US-002
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As the orchestrator agent, I want the Model Tier Decision Table and the Parallelism Rules + Agent Dispatch Template held in a standards file rather than duplicated inline in the always-loaded orchestrator, so that always-loaded context shrinks and model-id maintenance and parallelism guidance have one home.

## Functional Requirements
- Create `planifest-framework/standards/agent-dispatch-standards.md`, containing the Model Tier Decision Table (task type → tier → rationale, plus the tier-to-model mapping by tool) and the Parallelism Rules (MUST parallelise / Cannot parallelise tables) plus the Agent Dispatch Template (the concrete parallel dispatch skeleton and the self-contained prompt rule), relocated verbatim from `planifest-orchestrator/SKILL.md`
- Remove the Model Tier Decision Table and the Parallelism Rules + Agent Dispatch Template sections from `planifest-framework/skills/planifest-orchestrator/SKILL.md`, replacing them with a short pointer: "Consult `standards/agent-dispatch-standards.md` before spawning every subagent" and "Parallelism defaults and dispatch mechanics: see `standards/agent-dispatch-standards.md`"
- Update `planifest-framework/skills/planifest-ship-agent/SKILL.md`, which duplicates the Model Tier Decision Table per discovery.md's finding table, to replace its copy with the same pointer to `standards/agent-dispatch-standards.md`
- Update `planifest-framework/skills/planifest-codegen-agent/SKILL.md`, which currently cites "the orchestrator's canonical Parallelism Directive", to repoint that citation to `standards/agent-dispatch-standards.md` instead of the orchestrator

## Acceptance Criteria
- [x] `planifest-framework/standards/agent-dispatch-standards.md` exists and contains the full Model Tier Decision Table and the full Parallelism Rules + Agent Dispatch Template content, byte-for-byte preserved from their prior location (relocation, not rewording) - confirmed by independent P4 diff review
- [x] `planifest-orchestrator/SKILL.md` and `planifest-codegen-agent/SKILL.md` point to `standards/agent-dispatch-standards.md` for this content. **Correction:** `planifest-ship-agent/SKILL.md` was checked and found to have no duplicate Model Tier content to begin with (grep for "tier" found nothing) - ADR-001's assumed duplicate did not exist in the current file, so there was nothing to repoint there.
- [x] No behavioural change: the same table and rules are consulted at the same decision points, only from one file

## Dependencies
- req-001 (regression baseline) must be complete first
- Independent of req-002 (different content, different sections of the orchestrator), but must not be committed in a way that conflicts with req-002's edits to `planifest-orchestrator/SKILL.md` — coordinate section boundaries with req-002, or land as separate sequential commits touching non-overlapping lines
