---
title: "Requirement: req-002 - ship-agent P7 git add"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-002 - ship-agent P7 git add

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source:** US-002
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want the P7 archive commit's `git add` to explicitly name `plan/current/`, so that the archive commit doesn't silently depend on git's rename-detection heuristic.

## Functional Requirements
- `planifest-ship-agent/SKILL.md`'s P7 "Step 7 — Commit archive" `git add` command MUST explicitly list `plan/current/` as one of its path arguments, in addition to the paths it already stages (`plan/_archive/`, `plan/changelog/`, `docs/about.md`, `plan/.orchestrator-active`, `plan/.orchestrator-ack`, `plan/.run-mode`).
- The staging of `plan/current/`'s deletion (emptied by Step 6's copy-then-delete) MUST be achieved by naming the path directly in the `git add` invocation, not by relying on git's similarity-based rename detection to infer it from `plan/_archive/` being staged.

## Acceptance Criteria
- [ ] `planifest-ship-agent/SKILL.md` Step 7's documented `git add` command includes `plan/current/` as an explicit path argument alongside the six paths already listed.
- [ ] The updated command, when run after Step 6's copy-then-delete, stages `plan/current/`'s now-empty/deleted contents without requiring a separate manual `git add plan/current/` follow-up.
- [ ] No change to Step 6 (the archive copy-then-delete mechanics) or to which paths are archived — this requirement is scoped to the Step 7 `git add` invocation only.

## Dependencies
- `planifest-ship-agent/SKILL.md` Step 6 (Archive plan/current/) — Step 7 runs immediately after and depends on Step 6 having already emptied `plan/current/`.
