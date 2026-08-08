---
title: "Requirement: req-007 - Skill-Scope Principle ADR"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-007 - Skill-Scope Principle ADR

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Source:** US-007 (0000024)
**Priority:** could-have

## User Story

> One requirement doc = one user story.

As a framework maintainer, I want an ADR recording the "does this skill earn its place" governance test with the four TDD-loop skills as worked examples, so that future skill additions/removals are judged against a documented standard rather than a duplication argument alone.

## Functional Requirements

- This requirement's entire deliverable IS an Architecture Decision Record. There is no separate P1 artifact beyond this requirement doc — the ADR itself is produced at Phase 2 by `planifest-adr-agent`, not at P1 and not as codegen output.
- The ADR MUST state the skill-scope governance test explicitly: does the skill provide governance or traceability that the host tool (e.g. Claude Code's own TDD/agentic loop behavior) cannot provide on its own. A skill earns its place only if the answer is yes with a concrete, named mechanism (a gate it enforces, a state it records, an artifact it forces into existence) — not "it's good practice" or "it's more thorough."
- The ADR MUST apply the test to all four TDD-loop skills as worked "retain" examples: `planifest-test-writer`, `planifest-implementer`, `planifest-refactor`, and `planifest-verify-by-execution`.
- For each of the four worked examples, the ADR MUST record: the verdict (retain, and for `planifest-refactor` specifically the marginal variant of retain — see below), the specific governance/traceability mechanism the skill provides that the host tool alone would not, and the skill file's word count as a concrete artifact-weight data point.
- The ADR MUST record a marginal verdict on `planifest-refactor` distinct from the other three: its retain rationale is weaker (a host tool's own agentic loop can plausibly perform an equivalent refactor pass unprompted), so it is retained on current evidence but flagged as the weakest case of the four, not on equal footing with the other three.
- The ADR MUST include a forward-looking note that future skill additions should be checked against this test before being introduced into the pipeline.
- The ADR MUST include a forward-looking note that `planifest-refactor`'s marginal status means any future proposal to remove it must be evidenced by a build-assessment showing it added nothing in practice (e.g. `planifest-build-assessment-agent` output showing no refactor-phase governance value delivered across observed runs) — the duplication argument alone (host tool could theoretically do this) is not sufficient grounds for removal, since it was already known and weighed at the time of this ADR.

## Acceptance Criteria

- [ ] ADR exists at `plan/current/adr/` with the skill-scope-principle test stated and all four worked examples ( `planifest-test-writer`, `planifest-implementer`, `planifest-refactor`, `planifest-verify-by-execution` ) included, each with its verdict and word count
- [ ] `planifest-refactor`'s worked example is recorded with the marginal verdict, distinct from the other three's unqualified retain verdicts
- [ ] The ADR states that future skill additions should be checked against this test
- [ ] The ADR states that future removal of `planifest-refactor` must be evidenced by a build assessment showing it adds nothing, not by the duplication argument alone
- [ ] The orchestrator skill or a relevant process doc (e.g. a workflow or standards file governing skill additions) references this ADR for future skill additions

## Dependencies

- This requirement is fulfilled at Phase 2 (`planifest-adr-agent`), not Phase 3 codegen. No code is generated for this requirement — the ADR document is the complete deliverable. Sequencing note: this requirement carries no P1 artifact of its own beyond this requirement doc; P2 should treat it as a standard "significant decision" ADR input, sourced directly from this file rather than from an execution-plan NFR or scope entry.
- No dependency on the other 7 requirements in this feature; can be actioned independently and in parallel with any of them.
