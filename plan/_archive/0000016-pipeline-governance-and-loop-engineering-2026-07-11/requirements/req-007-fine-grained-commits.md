---
title: "Requirement: REQ-007 - Fine-Grained Phase Commits"
summary: "Commit after every meaningful artifact write within a phase, not only at phase gates."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-007 - Fine-Grained Phase Commits

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-007
**Priority:** must-have
**Wave:** 0

---

## User Story

As a human reviewing pipeline progress, I want the orchestrator and phase agents to commit locally after every meaningful artifact write within a phase — not batched until the single existing phase-gate commit — so that in-progress work is never more than one artifact away from being recoverable.

---

## Functional Requirements
- Orchestrator Hard Limit 7 is strengthened from "commit at each phase gate" to "commit after every meaningful artifact write, and at minimum at each phase gate"
- "Meaningful artifact write" is defined with per-phase examples: each requirement doc (P1), each ADR (P2), each requirement's completed TDD cycle (P3), each fix batch (P4), the security report (P5), each docs artifact group (P6)
- Phase skills (spec, adr, codegen, validate, security, docs) each carry a one-line commit directive referencing the definition — no skill re-defines it
- Commit messages follow the existing `commit-standards.md` unchanged; the granular cadence adds no new message format
- This aligns the framework with the repo override `custom-001-local-git-only.md` § "Commit Granularly, Continuously" (added 2026-07-11)

## Acceptance Criteria
- [ ] Hard Limit 7 text contains the per-artifact cadence and per-phase examples
- [ ] Each of the six phase skills contains the commit directive
- [ ] A P1 run on this very feature produces one commit per requirement batch rather than a single end-of-phase commit (self-demonstrating)

## Dependencies
- None
