---
title: "Requirement: REQ-009 - p0-preflight"
summary: "P0 pre-flight: check branch state, confirm PRs merged, offer feature branch creation."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-009 - p0-preflight

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-009
**Priority:** must-have

---

## User Story

As a pipeline orchestrator at P0 start, I check the current branch, confirm all previous PRs are merged, and offer to create the feature branch, so that every pipeline run starts from a clean known state.

---

## Functional Requirements
- A new "Pre-flight" step is added to `planifest-orchestrator/SKILL.md` Phase 0 Start Actions, numbered before the sentinel write (step 0)
- Pre-flight sequence:
  1. Run `git branch --show-current` and report the result to the human
  2. Ask: "Are all previous PRs merged and is main up to date?" — wait for confirmation
  3. If not on main: offer `git checkout main` — execute if human accepts
  4. After confirming main (or if already on main): offer to create feature branch `git checkout -b feat/{feature-id}` — execute if human accepts
  5. Note: `git pull` is not attempted (local-git-only constraint — no passphrase); human is responsible for confirming main is current
- Pre-flight runs only on fresh pipeline starts — not on resume (resume detection already confirms the branch context)

## Acceptance Criteria
- [ ] planifest-orchestrator/SKILL.md has a Pre-flight step before the sentinel write in Phase 0 Start Actions
- [ ] Pre-flight reports current branch to human
- [ ] Pre-flight asks about PR merge status
- [ ] Pre-flight offers checkout main if not already there
- [ ] Pre-flight offers feature branch creation
- [ ] Pre-flight is skipped on resume (pause.md detected)
- [ ] No `git pull` is attempted

## Dependencies
- None (pre-flight is the first action in a fresh P0)

## Input Validation

- [ ] Input source: stdout of `git branch --show-current`
- [ ] Allowed character pattern: `[a-zA-Z0-9/_\-.]` — standard git branch name characters
- [ ] Maximum length: 255 characters — truncate beyond this
- [ ] Failure behaviour: if command fails or returns empty, report "unknown branch" to human and continue — do not halt
- [ ] Logging policy: branch name displayed verbatim in human-facing output only; not injected into model context beyond the report line
