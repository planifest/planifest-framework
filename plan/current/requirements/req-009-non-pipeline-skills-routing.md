---
title: "Requirement: REQ-009 - Document and route non-pipeline skills"
summary: "planifest-implementer, planifest-optimise-agent, planifest-refactor, and planifest-test-writer exist in skills/ but are undiscoverable — no orchestrator routing, no description of when to use them."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-009 - Document and route non-pipeline skills

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** P0 audit — four skills exist in planifest-framework/skills/ that are not referenced in the orchestrator pipeline: planifest-implementer, planifest-optimise-agent, planifest-refactor, planifest-test-writer. They are either dead code or undiscoverable capability.
**Priority:** must-have

---

## User Story
As a framework user, I want to know what standalone skills are available and when to invoke them, so that I can use the full capability of the framework without guessing at skill names.

## Functional Requirements
- Each of the four skills (planifest-implementer, planifest-optimise-agent, planifest-refactor, planifest-test-writer) must be audited: read its SKILL.md to confirm its purpose and whether it is intentionally standalone or should be integrated into the pipeline
- For each skill confirmed as intentionally standalone:
  - Its SKILL.md `description` frontmatter field must clearly state the trigger condition (when a user should invoke it)
  - The orchestrator skill must reference it in a **Standalone Skills** routing table with: skill name, trigger condition, and relationship to the main pipeline phases
- For any skill found to be dead code (no clear purpose, duplicates a phase skill, or should be removed): raise a flag for human decision before any deletion — do not delete without explicit approval
- The orchestrator's **Routing Directive** section must be updated to include standalone skill routing alongside the existing Fast Path / Change Pipeline / Feature Pipeline decision tree

## Acceptance Criteria
- [ ] All four skills have been read and their purpose confirmed or flagged
- [ ] `planifest-orchestrator/SKILL.md` contains a Standalone Skills section listing each intentionally standalone skill with its trigger condition
- [ ] Each standalone skill's `description` frontmatter field accurately describes when to use it in one sentence
- [ ] No skill remains in `planifest-framework/skills/` without either a pipeline reference or a standalone routing entry
- [ ] If any skill is recommended for removal, a written recommendation is produced for human review — not acted on unilaterally

## Dependencies
- Must read each skill's SKILL.md before writing any routing entries (content determines classification)
