---
title: "Requirement: REQ-003 - subagent-decomposition"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - subagent-decomposition

**Feature:** 0000009-framework-rail-tightening
**Source:** Feature brief AC — phase agents decompose hard tasks into subagents
**Priority:** must-have

---

## Functional Requirements

- The orchestrator SKILL.md is updated to instruct each phase agent that, before tackling a difficult or multi-step task, it must:
  1. Search `planifest-framework/skills/` (and `planifest-overrides/capability-skills/` if present) for the most appropriate skill for the subtask
  2. Delegate to that skill as a subagent if a matching skill is found
  3. Select the appropriate model tier per the orchestrator's Model Tier Decision Table (primary for reasoning-heavy tasks, cheaper for mechanical tasks)
  4. Record the subagent dispatch in the build log (agent type, model tier, purpose)
- The instruction is added as a named section `## Subagent Decomposition Protocol` in the orchestrator SKILL.md
- Phase skills (spec-agent, codegen-agent, etc.) are NOT modified — the instruction lives in the orchestrator and is passed via context when phase skills are invoked

## Acceptance Criteria

- [ ] `planifest-framework/skills/planifest-orchestrator/SKILL.md` contains a `## Subagent Decomposition Protocol` section
- [ ] The section specifies: skill-library lookup path, delegation instruction, model-tier selection rule, build-log recording requirement
- [ ] The section does not duplicate content already present in phase skill files

## Dependencies

- None (orchestrator SKILL.md edit only)
