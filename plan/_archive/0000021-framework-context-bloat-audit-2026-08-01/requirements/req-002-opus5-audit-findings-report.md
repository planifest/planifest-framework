---
title: "Requirement: req-002 - Framework Context Bloat Audit"
summary: "Fresh-context claude-opus-5 audit pass producing a written findings report before any edit."
status: "active"
version: "0.1.0"
---
# Requirement: req-002 - Framework Context Bloat Audit

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000021-framework-context-bloat-audit
**Source:** US-001
**Priority:** must-have

---

## User Story

As the human running Planifest pipelines, I want the framework's skill/instruction content audited by a fresh-context Opus 5 agent, so that redundant boilerplate is identified before any edit is made.

---

## Functional Requirements
- Dispatch a fresh-context subagent on `claude-opus-5` (model-tier override for this feature, recorded in design.md) to read every `planifest-framework/skills/*/SKILL.md` file, every file under `planifest-framework/standards/`, every file under `planifest-framework/templates/`, and the root `CLAUDE.md`.
- For each file, the agent classifies content into: load-bearing (Hard Limits, STOP gates, enforcement-referenced instructions, project-specific/non-obvious conventions) vs. redundant/restated/model-implicit (generic explanation a current-generation model already infers, restated conventions, boilerplate).
- The agent produces one written findings report (`plan/current/audit-findings-report.md`) listing, per file: current line count, classified redundant sections/lines with a one-line rationale each, and a recommended target line count (floor: no less than a 20% cut across the `skills/*/SKILL.md` corpus in aggregate, no fixed per-file ceiling).
- The findings report must not itself propose edits to `.claude/` (out of scope) or propose the structural router/`references/` decomposition of the orchestrator (deferred, backlog 0000020).
- This requirement only begins once req-001's baseline artifact exists.

## Acceptance Criteria
- [ ] `plan/current/audit-findings-report.md` exists, covering every `SKILL.md`, every `standards/*.md`, every `templates/*.md`, and root `CLAUDE.md`
- [ ] Every flagged redundant section has a one-line rationale distinguishing it from load-bearing content
- [ ] The report was produced by a fresh-context `claude-opus-5` subagent, not the orchestrator's own running context
- [ ] The report contains no proposal to edit `.claude/` and no structural router/`references/` decomposition proposal for the orchestrator

## Dependencies
- Depends on req-001 (baseline must exist first)
