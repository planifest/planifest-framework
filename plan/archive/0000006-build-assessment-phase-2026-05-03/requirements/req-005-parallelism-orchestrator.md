---
title: "Requirement: req-005 - parallelism directives in orchestrator"
status: "active"
version: "0.1.0"
---
# Requirement: req-005 - parallelism directives in orchestrator

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** "why tasks aren't parallelised more often"
**Priority:** must-have

---

## Functional Requirements
- The orchestrator skill MUST contain an explicit **Parallelism Rules** section
- The rules MUST state: independent research tasks with no shared state MUST be dispatched in parallel (single message, multiple Agent tool calls)
- The rules MUST state: phase skills that operate on independent components MUST be invoked in parallel where the tool supports it
- The rules MUST state: the default posture is parallel — sequential dispatch requires an explicit dependency justification
- The rules MUST provide a dependency test: "Can task B start before task A's output is available? If yes, dispatch in parallel."
- The rules MUST list common parallel patterns:
  - Multiple codebase search tasks → parallel
  - Hook/adapter research across different tools → parallel
  - Independent document reads → parallel
  - Background test runner while writing docs → parallel
- The rules MUST list what CANNOT be parallelised:
  - Tasks where B consumes A's output
  - Sequential phases where later phases depend on earlier phase artefacts
- The build log MUST record parallel task count per phase

## Acceptance Criteria
- [ ] Orchestrator SKILL.md contains a "Parallelism Rules" section
- [ ] Section states the default posture is parallel
- [ ] Section includes the dependency test
- [ ] Section lists at least 4 common parallel patterns
- [ ] Section lists what cannot be parallelised

## Dependencies
- req-001 (build-log records parallel task counts)
