---
title: "Requirement: req-005 - Sub-agent model tier convention"
status: "active"
version: "0.1.0"
---
# Requirement: req-005 - Sub-agent model tier convention

**Skill:** planifest-spec-agent
**Feature:** 0000004-tdd-regression-test-quality
**Source:** User Story 1 — cost mitigation for 3 sub-agents × N requirements
**Priority:** must-have

---

## Functional Requirements
- Each of the three TDD sub-agent SKILL.md files (test-writer, implementer, refactor) MUST include a `recommended_model` field in their YAML frontmatter.
- The `recommended_model` value MUST be `haiku` (or equivalent cheaper model tier per the active tool's model naming scheme).
- Each SKILL.md MUST contain a rationale section explaining why a cheaper model is appropriate for that skill's narrow, well-defined task.
- The orchestrating codegen-agent MUST document that it retains the full model for orchestration and synthesis, and that sub-agents are invoked at a cheaper tier.
- The `recommended_model` frontmatter field MUST be treated as a convention: it is a signal to the invoking orchestrator, not a hard runtime enforcement.

## Acceptance Criteria
- [ ] `planifest-test-writer/SKILL.md` frontmatter contains `recommended_model: haiku`.
- [ ] `planifest-implementer/SKILL.md` frontmatter contains `recommended_model: haiku`.
- [ ] `planifest-refactor/SKILL.md` frontmatter contains `recommended_model: haiku`.
- [ ] Each SKILL.md body includes a section titled "Model Tier Rationale" or equivalent.
- [ ] `planifest-codegen-agent/SKILL.md` updated section states sub-agents SHOULD use cheaper model tier.
- [ ] An ADR documents the model tier selection decision (see ADR requirements).

## Dependencies
- req-002, req-003, req-004 (the skills that carry the frontmatter field)
- req-001 (codegen-agent update where the convention is applied)
