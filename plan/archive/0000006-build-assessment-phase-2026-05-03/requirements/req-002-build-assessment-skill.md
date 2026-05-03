---
title: "Requirement: req-002 - planifest-build-assessment-agent skill"
status: "active"
version: "0.1.0"
---
# Requirement: req-002 - planifest-build-assessment-agent skill

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** "Phase 8 which will be Build Assessment. You will create a report like you just did which will be filed in the archived dir."
**Priority:** must-have

---

## Functional Requirements
- A new skill `planifest-build-assessment-agent` MUST exist at `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md`
- The skill MUST have valid YAML frontmatter with `name: planifest-build-assessment-agent` and `description`
- The skill MUST read `plan/current/build-log.md` as its primary input
- The skill MUST produce a structured build report covering: model tier usage, skills invoked per phase, agents spawned (count and type), MCP tools used (counts), parallel task bursts, self-corrections, artefact counts
- The report MUST be written to `plan/archive/{feature-id}-{date}/build-report.md`
- The skill MUST include an "Efficiency Observations" section noting: whether cheaper model tiers were used where applicable, whether parallelism was applied, any phases that could have been faster

## Acceptance Criteria
- [ ] `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md` exists
- [ ] YAML frontmatter `name` matches directory name
- [ ] Skill body references `plan/current/build-log.md` as input
- [ ] Skill body includes report sections: Model Usage, Skills Invoked, Subagent Dispatch, MCP Tool Usage, Parallel Task Bursts, Self-Corrections, Artefact Counts, Efficiency Observations
- [ ] Skill body specifies output path pattern `plan/archive/{feature-id}-{date}/build-report.md`

## Dependencies
- req-001 (build-log.md is the input to this skill)
- req-003 (P8 must be wired in orchestrator to invoke this skill)
