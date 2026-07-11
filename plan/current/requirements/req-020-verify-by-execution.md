---
title: "Requirement: REQ-020 - Verify-by-Execution Skill"
summary: "P4 verifies acceptance criteria by running the software, not only reading code and test output."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-020 - Verify-by-Execution Skill

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-020
**Priority:** must-have
**Wave:** 1

---

## User Story

As the P4 validate-agent, I load `planifest-verify-by-execution` to verify acceptance criteria by running the software (browser MCP click-through, real API calls, log/DB checks) rather than only reading code and test output, so that "done" reflects observed behaviour.

---

## Functional Requirements
- A `planifest-verify-by-execution` skill exists, invoked by the validate-agent after CI checks pass, toggle-gated (`verify_by_execution`, default off)
- For each acceptance criterion it selects an observation method by target type: browser MCP click-through (web UI), real API call (service), CLI invocation (tool/script), log or file inspection (side effects) — reading test output alone never counts as verification
- Per-criterion results (verified / not-verifiable / failed, with the observation evidence) are written to a verification report in `plan/current/`; failures feed P4's existing self-correction loop (cap 5, unchanged)
- Criteria that genuinely cannot be executed (e.g. requires production credentials) are marked not-verifiable with a reason — never silently passed

## Acceptance Criteria
- [ ] At least one acceptance criterion on a real feature is verified by executing the software, with observation evidence in the report
- [ ] A seeded behavioural failure (tests pass, runtime behaviour wrong) is caught and fed to self-correction
- [ ] With the toggle off, P4 behaviour is unchanged

## Dependencies
- REQ-009, REQ-011
