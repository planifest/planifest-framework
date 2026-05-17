---
title: "Requirement: req-001 - build-log working file"
status: "active"
version: "0.1.0"
---
# Requirement: req-001 - build-log working file

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** "a working file in the current plan as it progresses for all the build info"
**Priority:** must-have

---

## Functional Requirements
- The orchestrator MUST create `plan/current/build-log.md` at Phase 0 from `build-log.template.md`
- The orchestrator MUST append a phase entry to `plan/current/build-log.md` at the start of each phase (P0–P8), recording: phase name, timestamp, model tier used, skills invoked, agents spawned, MCP tools called, parallel task count
- The build log MUST survive session changes — it is a plain Markdown file committed to the repo with the rest of `plan/current/`
- If `plan/current/build-log.md` already exists on resume, the orchestrator MUST append to it (not overwrite)
- The build log MUST include a summary section updated at P7 with totals: total agents spawned, total MCP calls, phases using parallelism, model tier breakdown

## Acceptance Criteria
- [ ] `planifest-framework/templates/build-log.template.md` exists
- [ ] Orchestrator skill instructs creation of `plan/current/build-log.md` at P0
- [ ] Orchestrator skill instructs per-phase append entries
- [ ] Orchestrator skill instructs resume detection to append rather than overwrite
- [ ] Build log template includes fields: phase, timestamp, model_tier, skills_invoked, agents_spawned, mcp_calls, parallel_tasks

## Dependencies
- req-007 (build-log.template.md must exist before orchestrator can reference it)
