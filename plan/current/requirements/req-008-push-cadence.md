---
title: "Requirement: REQ-008 - Feature-Branch Remote Push Cadence"
summary: "Push the feature branch after every phase-gate commit when push is authorized for the session."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-008 - Feature-Branch Remote Push Cadence

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-008
**Priority:** must-have
**Wave:** 0

---

## User Story

As a human tracking pipeline progress remotely, I want the orchestrator to push the feature branch after every phase-gate commit when push is authorized for the session, so that progress is visible and backed up without waiting for P9.

---

## Functional Requirements
- Orchestrator documents a push-cadence rule: after each phase-gate commit, if remote push is authorized, push the feature branch; if not authorized, skip silently (no prompt per phase)
- Authorization source, in priority order: a standing override in `planifest-overrides/instructions/` (if the human chooses to add one), else an explicit per-session grant recorded in the build log at P0
- Push failures (auth, network) are reported once and never block the pipeline — commits remain local and the human is told the branch is ahead
- Decision deferred from P0: whether to make push standing in `custom-001-local-git-only.md` is finalized at P3 with the human

## Acceptance Criteria
- [ ] Orchestrator skill contains the push-cadence rule with the two-level authorization source
- [ ] With no authorization, a full pipeline run performs zero remote git operations
- [ ] A failed push is reported and the pipeline continues

## Dependencies
- REQ-007 (gate commits are the push trigger points)
