---
title: "Requirement: req-006 - parallelism directives in phase skills"
status: "active"
version: "0.1.0"
---
# Requirement: req-006 - parallelism directives in phase skills

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** "why tasks aren't parallelised more often"
**Priority:** must-have

---

## Functional Requirements
- The following phase skills MUST each contain a parallelism directive appropriate to their phase:
  - `planifest-spec-agent`: requirement files for independent features MUST be written in parallel
  - `planifest-adr-agent`: independent ADRs (no cross-references between them) MUST be written in parallel
  - `planifest-codegen-agent`: independent component implementations MUST be generated in parallel; test and implementation files for a single component SHOULD be written in a single pass (not sequential)
  - `planifest-validate-agent`: lint, typecheck, and test commands MUST be run in parallel where the tool supports parallel Bash calls
  - `planifest-security-agent`: independent component security reviews MUST be done in parallel
  - `planifest-docs-agent`: independent documentation sections MUST be written in parallel
- Each directive MUST be placed in a visible section titled "Parallelism" or "Parallelism Directive" within the skill
- The directive MUST use the word "MUST" (not "should" or "can") to signal it is a behavioural requirement, not a suggestion

## Acceptance Criteria
- [ ] `planifest-spec-agent` SKILL.md contains a parallelism directive
- [ ] `planifest-adr-agent` SKILL.md contains a parallelism directive
- [ ] `planifest-codegen-agent` SKILL.md contains a parallelism directive
- [ ] `planifest-validate-agent` SKILL.md contains a parallelism directive
- [ ] `planifest-security-agent` SKILL.md contains a parallelism directive
- [ ] `planifest-docs-agent` SKILL.md contains a parallelism directive
- [ ] Each directive uses "MUST" (not "should")

## Dependencies
- None (independent skill edits)
