---
title: "ADR 003: Skill-scope principle — does this skill earn its place"
summary: "Records the governing test for whether a skill provides governance or traceability the host tool cannot, with the four TDD-loop skills as worked examples, so future skill additions and removals are judged against a documented standard."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Skill-scope principle — does this skill earn its place

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

Backlog `0000024` (this feature's req-007) originated from an independent framework review whose first edition proposed deprecating `planifest-test-writer`, `planifest-implementer`, `planifest-refactor`, and `planifest-verify-by-execution` as duplicating host-tool (Claude Code) behaviour. That review proposed the right test — does this skill provide governance or traceability the host tool cannot — but did not apply it before recommending deprecation. Applying the test to all four retains them, with one marginal case. Left unrecorded, the same duplication argument could resurface against these or future skills without the counter-test being applied again, and nothing today stops the skills corpus accreting re-specifications of host behaviour as host tools improve.

## Decision

Adopt the following test for any skill's continued inclusion in the framework, and for any newly-proposed skill: **does this skill provide governance or traceability the host tool cannot?** A skill that merely restates host-tool default behaviour without adding an enforced constraint, an audit trail, or a structural guarantee does not earn its place. Applied to the four skills in question:

| Skill | Words | Verdict | Rationale |
|-------|-------|---------|-----------|
| `planifest-test-writer` | 586 | Retain | Enforces one failing test per requirement and RED confirmation by non-zero exit before implementation begins. Host tools permit test-first; they do not enforce it. |
| `planifest-implementer` | 557 | Retain | Enforces minimum-code-to-green with a verified zero exit, gated on the prior RED. The constraint is the ordering, not the code-writing itself. |
| `planifest-refactor` | 528 | Retain, marginal | Thinnest of the four; its governance content is close to host-tool default behaviour. Retained on the current evidence, not on the same footing as the other three. |
| `planifest-verify-by-execution` | 481 | Retain | Encodes "do not accept test output as proof — run the software," the opposite of host-tool default behaviour (which stops at green tests). |

Together these total 2,152 words, roughly 7% of the skills corpus at the time of the original review — the maintenance-liability argument for removing them does not survive the sizes involved. Reference this ADR from the process that adds a new skill (`planifest-orchestrator/SKILL.md`'s Capability Skills / skill-scope guidance) so the test is applied at the point of addition, not only retrospectively when a future review raises the question again.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Deprecate all four per the original review's proposal | Smaller skills corpus | The review's own test, applied, does not support deprecation — three skills clearly retain, one is marginal but not absent | Contradicted by applying the review's own stated test |
| Deprecate only `planifest-refactor` (the marginal one) now | Removes the weakest case immediately | No evidence yet that it adds nothing in practice — the marginal verdict is about thinness of documented governance, not proven redundancy | Premature; req-007 itself specifies that any future removal needs build-assessment evidence, not this analysis alone |
| Leave the test unrecorded, rely on future reviewers to re-derive it | No new artifact | Exactly the failure mode that produced the first-edition review's own error — repeating this without a durable record risks the same mistake recurring | The point of an ADR is to make this checkable, not re-argued from scratch each time |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | Governs future decisions about `planifest-test-writer`, `planifest-implementer`, `planifest-refactor`, `planifest-verify-by-execution`, and any newly-proposed skill; referenced (not restated) from the orchestrator's skill-addition guidance |

## Consequences

**Positive:**
- Future skill-addition or skill-removal debates have a documented, applicable test rather than relying on a duplication argument alone.
- `planifest-refactor`'s marginal status is explicitly on record, so a future removal decision has to produce build-assessment evidence rather than re-litigate the duplication argument.

**Negative:**
- One more ADR for future contributors to be aware of before proposing skill changes — a small ongoing reading cost.

**Risks:**
- The test itself ("governance or traceability the host tool cannot") could be applied inconsistently by different reviewers without concrete worked examples to anchor it — mitigated by this ADR recording all four current worked examples, including the marginal one, as calibration points.

## Related ADRs

- None — this is the first ADR recording this specific governance test.

## Supersedes

- None

## Superseded By

- None
