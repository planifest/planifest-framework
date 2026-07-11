---
title: "Requirement: REQ-014 - Mechanical Consistency Checks"
summary: "Deterministic script validating cross-artifact consistency, immune to model self-grading."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-014 - Mechanical Consistency Checks

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-014
**Priority:** must-have
**Wave:** 1

---

## User Story

As the design-critic, I run a deterministic script validating cross-artifact consistency, so that the cheapest verifier layer is immune to model self-grading.

---

## Functional Requirements
- A Node ≥20 `.mjs` script exists (`planifest-framework/scripts/consistency-check.mjs`) checking, over `plan/current/`: every user story maps to ≥1 requirement file and vice versa (story↔requirement traceability); every component named in requirements is declared in design.md; no requirement exceeds 3 acceptance criteria; every risk-register entry has a mitigation; no ADR is referenced that does not exist
- Output: human-readable findings list + non-zero exit when any check fails; zero exit when clean
- The script has no model dependency — pure file parsing — and can run standalone or from the critic
- Shell-based framework tests cover it with a seeded-defect fixture (one violation per check type)

## Acceptance Criteria
- [ ] Script catches every seeded defect class in the test fixture (5/5) and exits non-zero
- [ ] Clean fixture exits zero with no findings
- [ ] Runs standalone via `node scripts/consistency-check.mjs` with no network or model access

## Dependencies
- None (REQ-013 consumes it)
