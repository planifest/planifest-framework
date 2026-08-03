---
title: "Requirement: req-006 - docs-agent continuous_run respect"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-006 - docs-agent continuous_run respect

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source:** US-006
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want `planifest-docs-agent`'s P6 Gate B (and any phase skill with the same pattern) to check `continuous_run` before stopping for confirmation, so that a continuous-run session isn't interrupted by redundant prompts.

## Functional Requirements
- `planifest-docs-agent/SKILL.md`'s P6 Gate B step must check `plan/.run-mode` / `continuous_run` before stopping for human confirmation.
- When `continuous_run` is active, Gate B must present its assessment and recommendation as a logged statement (not a question) and proceed automatically, instead of stopping with "Confirm? (proceed / skip docs update / update different docs)".
- When `continuous_run` is not active, Gate B must retain its current behavior: present the assessment and wait for the human to confirm before proceeding.
- The auto-accepted decision (when `continuous_run` is active) must be recorded in the P6 build log block, same as a human-confirmed decision is today.
- Every other phase skill with an internal confirmation gate of the same pattern (a skill-level "stop and ask" step distinct from the orchestrator's own Phase Invocation Table STOP, which already gates on `continuous_run`) must be audited for the same defect: `planifest-spec-agent`, `planifest-adr-agent`, `planifest-codegen-agent`, and any other phase skill under `.claude/skills/planifest-*`.
- Any additional instance of the pattern found during the audit must be fixed using the same approach as Gate B (check `continuous_run`, state instead of ask when active, log the decision, proceed).

## Acceptance Criteria
- [ ] `planifest-docs-agent/SKILL.md` Gate B checks `continuous_run` before stopping for confirmation.
- [ ] In continuous-run mode, Gate B logs its assessment and recommendation as a statement in the P6 build log block and proceeds without stopping.
- [ ] In non-continuous-run mode, Gate B's existing stop-and-confirm behavior is unchanged.
- [ ] `planifest-spec-agent`, `planifest-adr-agent`, `planifest-codegen-agent`, and all other phase skills under `.claude/skills/planifest-*` are audited for the same skill-internal-gate-ignoring-`continuous_run` pattern, and the audit's findings are recorded.
- [ ] Every instance found by the audit is fixed to check `continuous_run` using the same statement-log-proceed approach as Gate B.
- [ ] The orchestrator's own Phase Invocation Table STOP/exception logic (which already gates on `continuous_run`) is left unchanged — this requirement only touches skill-internal gates.

## Dependencies
- `plan/.run-mode` / the orchestrator's `continuous_run` flag (existing mechanism, not introduced by this requirement).
- Depends on the audit step completing before its findings can be fixed; the audit itself must run before or alongside other phase-skill edits from this feature's remaining stories, to avoid conflicting concurrent edits to the same skill files.
