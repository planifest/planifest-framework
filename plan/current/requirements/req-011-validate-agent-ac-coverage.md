---
title: "Requirement: REQ-011 - Validate-agent must check acceptance criteria coverage, not just req-ID mapping"
summary: "The validate-agent verifies every requirement has a test (by req-ID), but does not verify that each acceptance criterion within a requirement is individually exercised."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-011 - Validate-agent must check acceptance criteria coverage, not just req-ID mapping

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** P0 audit — planifest-validate-agent/SKILL.md Step 1 checks "every functional requirement from plan/current/requirements/ has a mapped, executing test case identifiable by its req-ID" — but a single test can reference a req-ID without covering all acceptance criteria within that requirement doc.
**Priority:** should-have

---

## User Story
As a framework maintainer, I want the validate-agent to confirm that all acceptance criteria in each requirement doc are exercised by tests, so that a passing test suite is meaningful evidence of feature completeness rather than just structural compliance.

## Functional Requirements
- `planifest-framework/skills/planifest-validate-agent/SKILL.md` Step 1 (Semantic Correctness) must be updated to require:
  - For each requirement file in `plan/current/requirements/`, read its `## Acceptance Criteria` checklist
  - Verify that the test suite contains at least one test case that can be mapped to each individual acceptance criterion (by description or by a structured AC-ID comment in the test)
  - If a criterion has no mapped test, report it as a semantic validation failure — do not silently pass
- The validate-agent must produce a coverage table in its output: `REQ-ID | AC | Covered by test | Pass/Fail`
- The validate-agent must NOT require a 1:1 test-per-AC mapping — one test may cover multiple ACs if the test description clearly encompasses them
- If a requirement has no `## Acceptance Criteria` section (malformed doc), the validate-agent must flag it as a doc gap and continue rather than halt

## Acceptance Criteria
- [ ] `planifest-validate-agent/SKILL.md` Step 1 explicitly requires AC-level coverage check, not just req-ID presence
- [ ] The skill instructs the agent to produce a coverage table per-requirement showing AC coverage
- [ ] The skill specifies: missing AC coverage = semantic validation failure (not a warning)
- [ ] The skill specifies: malformed requirement doc (no AC section) = doc gap flag, not a halt
- [ ] The skill does not require 1:1 test-per-AC; it permits one test to cover multiple ACs with clear description

## Dependencies
- REQ-007 (AC format standardised in requirement template) makes this check reliable
