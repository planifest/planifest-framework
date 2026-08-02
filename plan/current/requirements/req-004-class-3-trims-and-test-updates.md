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
- Trim the expository asides identified in discovery: Hard Limit 7's push-cadence paragraph and Hard Limit 10's rationale essay, keeping each operative rule and cutting only the explanatory justification prose around it
- Trim P0 coaching asides that explain rather than instruct (for example "Deferred is not the same as missing" and "This is the contract between you and the human"), wherever a sentence can be cut without losing an operative instruction
- Grep planifest-framework/tests/regression/ for every regression test that asserts against content in planifest-orchestrator/SKILL.md, and treat the discovery list (test-0000009-rail-tightening.sh, test-0000018-req-003-orchestrator-marker-check-and-prompt.sh, test-0000018-req-004-phase-skill-telemetry-rewrite.sh, test-skill-telemetry.sh) as a starting point to verify, not as exhaustive
- For each test found, classify the content it checks as removed by req-002, relocated by req-002 or req-003, or untouched by this feature, and update assertions for relocated content to check the new canonical location
- If a test's assertion can no longer be satisfied because the underlying rule was judged non-essential, stop and escalate to the human on the loop rather than deleting or weakening the check; this feature removes duplication only and never removes a rule

## Acceptance Criteria
- [ ] Every regression test that greps orchestrator content is enumerated via a grep across planifest-framework/tests/regression/ before any trim edit lands, and the enumeration is recorded in this requirement's dependent work
- [ ] Each affected test's assertions are updated to match the new canonical location, landing in the same commit as the relocation or removal that made the old assertion stale
- [ ] No regression test is deleted or weakened
- [ ] The expository asides listed above are trimmed with zero loss of any operative instruction

## Dependencies
- req-002 and req-003 must be substantially complete first, since the test updates in this requirement need the final canonical locations those two requirements choose
