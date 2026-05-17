---
title: "Requirement: req-007 - build-log.template.md"
status: "active"
version: "0.1.0"
---
# Requirement: req-007 - build-log.template.md

**Skill:** spec-agent
**Feature:** 0000006-build-assessment-phase
**Source:** "There should be a working file in the current plan as it progresses for all the build info"
**Priority:** must-have

---

## Functional Requirements
- `planifest-framework/templates/build-log.template.md` MUST exist
- The template MUST include a header section with: feature ID, pipeline start timestamp, tool name, primary model name
- The template MUST include a per-phase entry block with fields: phase, start timestamp, model tier used, skills loaded, agents spawned (count), MCP calls (count), parallel task batches (count), notes
- The template MUST include a summary table at the bottom for totals: total phases, total agents, total MCP calls, phases with parallelism, model tier breakdown (primary vs cheaper counts)
- The template MUST use Markdown table format for machine-parseable structure
- The template MUST include placeholder tokens (e.g. `{{feature-id}}`, `{{start-timestamp}}`) so the orchestrator can fill it in at creation time

## Acceptance Criteria
- [ ] `planifest-framework/templates/build-log.template.md` exists
- [ ] Template contains a header section with feature ID and model fields
- [ ] Template contains a per-phase entry block
- [ ] Template contains a summary totals section
- [ ] Template uses `{{placeholder}}` tokens

## Dependencies
- None
