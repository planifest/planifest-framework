---
title: "Requirement: REQ-010 - capability-skill-intake"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-010 - capability-skill-intake

**Feature:** 0000005-framework-governance
**Source:** capability skill intake user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- `planifest-framework/skills-inbox/` must exist as a drop-zone directory (`.gitkeep`); a human may place any SKILL.md file here at any point during a pipeline run
- planifest-orchestrator SKILL.md must scan `planifest-framework/skills-inbox/` at the start of every phase transition (not only at P0)
- On detecting a SKILL.md in the inbox, the orchestrator must: read its frontmatter, summarise what the skill does, and ask the human: "Use for this plan only, or add permanently for all future plans?"
- After the human answers, the orchestrator must move the skill to the correct location atomically — `plan/current/capability-skills/{name}/` for one-time, `planifest-framework/capability-skills/{name}/` for permanent — then clear it from the inbox and update the appropriate registry
- If the human does not answer (defers), the skill remains in the inbox and is re-presented at the next phase transition
- The inbox scan must not block the phase transition if the inbox is empty

## Acceptance Criteria

- [ ] `planifest-framework/skills-inbox/` directory exists
- [ ] Orchestrator scans inbox at every phase transition
- [ ] Orchestrator presents summary and classification question on detection
- [ ] Skill moved to correct location after classification; inbox cleared
- [ ] Empty inbox does not delay phase transition

## Dependencies

- REQ-011 (skill-registries) — classification writes to registries
- REQ-012 (skill-manifest-in-design) — design.md updated after intake
