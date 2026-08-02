---
title: "Requirement: req-004 - class-3-trims-and-test-updates"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-004 - class-3-trims-and-test-updates

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Source:** US-003
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As the framework maintainer, I want the orchestrator's expository asides trimmed and every regression test that pins content moved or removed by req-002 or req-003 updated to assert the new canonical location, so that the trim is verified lossless.

## Functional Requirements
- Trim Hard Limit 10's rationale essay only, keeping the operative rule and cutting the explanatory justification prose around it. **Correction (post-baseline):** Hard Limit 7's push-cadence sentence is withdrawn from this trim - test-0000016-pipeline-governance.sh pins "push the feature branch" from that exact sentence, confirming it is operative, not expository. Hard Limit 7 is left untouched by this feature.
- Trim P0 coaching asides that explain rather than instruct (for example "Deferred is not the same as missing" and "This is the contract between you and the human"), wherever a sentence can be cut without losing an operative instruction
- The regression test enumeration is complete as of req-001's baseline run (plan/current/regression-baseline.md): 10 of 22 tests pin planifest-orchestrator/SKILL.md content, not the 4 originally estimated at P0. Use that table as the authoritative list, not the superseded P0 discovery estimate.
- Of the 10, exactly one requires an assertion update: test-0000006-build-assessment.sh, whose Model Tier and Parallelism Rules assertions must move from checking $ORCH (orchestrator content) to checking the new planifest-framework/standards/agent-dispatch-standards.md file, landing in the same commit as req-003's relocation.
- The remaining 9 require no assertion change, either because their pinned content is untouched by this feature's plan, or because req-002 was narrowed (Mode Taxonomy scope, reversal-assessor name retention) specifically to keep their assertions satisfied - re-verify this by running each of the 9 individually after req-002 and req-003 land, not by assumption.
- If a test's assertion can no longer be satisfied because the underlying rule was judged non-essential, stop and escalate to the human on the loop rather than deleting or weakening the check; this feature removes duplication only and never removes a rule

## Acceptance Criteria
- [ ] test-0000006-build-assessment.sh's Model Tier / Parallelism Rules assertions are updated to check standards/agent-dispatch-standards.md, in the same commit as req-003's relocation
- [ ] The other 9 orchestrator-pinning tests are individually re-run after req-002 and req-003 land and confirmed still passing, with no assertion changes needed
- [ ] No regression test is deleted or weakened
- [ ] Hard Limit 10's rationale essay and the named P0 coaching asides are trimmed with zero loss of any operative instruction; Hard Limit 7 is confirmed untouched

## Dependencies
- req-002 and req-003 must be substantially complete first, since the test updates in this requirement need the final canonical locations those two requirements choose
