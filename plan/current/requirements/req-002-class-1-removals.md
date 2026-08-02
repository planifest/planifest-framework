---
title: "Requirement: req-002 - class-1-removals"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-002 - class-1-removals

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Source:** US-001
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As the human on the loop, I want content in planifest-orchestrator/SKILL.md that is already fully and correctly stated elsewhere removed from the orchestrator and replaced with a pointer, so that the two copies cannot drift apart.

## Functional Requirements
- Before each removal below, read the named canonical file and confirm it already states the content correctly. Do not remove the orchestrator content first and check the canonical source afterward.
- Remove the telemetry event table (the 14-event reference table) and the JSON snippet examples from SKILL.md; replace with a pointer to planifest-framework/standards/telemetry-standards.md. Retain in SKILL.md: the failure-marker check duty, the per-phase Telemetry build-log line requirement, and phase_skip ownership.
- Remove the per-phase Input/Produces/Gate prose blocks for Phase 1 through Phase 7 from SKILL.md; replace with a pointer to each phase's own skill (planifest-spec-agent, planifest-adr-agent, planifest-codegen-agent, planifest-validate-agent, planifest-security-agent, planifest-docs-agent, planifest-ship-agent). Retain in SKILL.md: a single compact table listing phase number, skill to load, the STOP rule and its exception, and the design-critic/cross-model-review toggle note.
- Remove the Fast Path criteria list and Fast Path execution steps from SKILL.md; replace with a pointer to planifest-framework/workflows/fast-path.md. Retain in SKILL.md: the routing table row pointing to it.
- **Direction reversed (corrected during execution, see regression-baseline.md):** test-0000017-req-005-scope-lock-suggested-answers.sh pins the "Suggested-answer option" mechanics (accept/edit/reject, never-silently-skipped, build-log recording) inside the ORCHESTRATOR's own SKILL.md, confirming this is the canonical copy, not a duplicate to be removed. The actual duplication runs the other way: planifest-scope-lock-agent/SKILL.md's Invocation Contract restated the same dispatch/spawn-contents/recording facts. Fix: trim scope-lock-agent's Invocation Contract to point back at the orchestrator's Scope Lock Challenge section instead, leaving its unique Drafting Rules table untouched. Orchestrator word count unaffected by this item; the duplication is still removed.
- **Withdrawn during execution (see regression-baseline.md and build-log.md):** inspection of planifest-reversal-assessor/SKILL.md and planifest-loop-runner/SKILL.md found the "Execute (grant only)" and "Human gates" steps genuinely orchestrator-unique - the assessor's file owns only its own Assess-step rubric/verdict format, and loop-runner owns only generic budget-persistence/cap mechanics, neither restates what the orchestrator does after a grant or which conditions stop the pipeline. No removal made; req-002's own "confirm the canonical target already states it" check correctly found no duplication to remove here.
- Narrow removal (corrected after the req-001 baseline run, see regression-baseline.md "Corrections Applied"): remove only the Retrofit 6-step scan list and the four Mode Taxonomy subsections' bullet lists (Greenfield/Standard Iterative/Retrofit/External Anchor) that literally restate discovery.template.md's own per-mode subsections; replace with a pointer to planifest-framework/workflows/retrofit.md and planifest-framework/templates/discovery.template.md. Do NOT remove the "Structured Discovery Pass (all modes)" preamble (shared header, lifecycle, partial-failure, cross-session rules) - this is orchestrator-owned operative logic, not template-content description, and is pinned by test-0000017-req-006-structured-discovery-pass.sh. Retain in SKILL.md: the mode taxonomy table, the conflict-warning protocol, and the full Structured Discovery Pass preamble.
- Remove the Change Pipeline's three confirm questions (which feature/component/change) from SKILL.md; replace with a pointer to planifest-framework/workflows/change-pipeline.md. Retain in SKILL.md: "route to change-agent, confirm scope per the workflow."
- Collapse the triple-stated "load the phase skill before acting" instruction to a single statement in Phase Conventions: remove the Framework Index rows that repeat "Begin Phase N -> load skill X" for phases 1-9, and remove the restatement inside each per-phase section.
- Land each of the eight removals above as its own commit.

## Acceptance Criteria
- [ ] All 8 items above are removed from planifest-orchestrator/SKILL.md and replaced with a one-line pointer where a pointer is called for
- [ ] For each removal, the canonical target file was read and confirmed correct before the corresponding SKILL.md edit was made
- [ ] No behavioural change: every rule removed is still stated, in full, in exactly one file
- [ ] Each of the 8 items lands as its own commit, not batched together

## Dependencies
- req-001 (regression baseline) must be complete and committed first
- Corrected against req-001's actual test inventory (10 of 22 tests pin orchestrator content, not the 4 originally estimated at P0) - see plan/current/regression-baseline.md "Corrections Applied Before Any Edit" for the reversal-assessor-name and Mode-Taxonomy narrowing captured above
