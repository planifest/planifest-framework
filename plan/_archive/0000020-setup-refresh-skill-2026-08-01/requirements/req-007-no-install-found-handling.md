---
title: "Requirement: REQ-007 - No install found handling"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-007 - No install found handling

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-001 (first-run scenario)
**Priority:** must-have

---

## User Story

As a human on the loop, if I run the refresh skill on a repo with no Planifest install for the named tool (or for any tool, if I didn't name one), I want the skill to tell me plainly rather than attempt a refresh that has nothing to work from.

---

## Functional Requirements
- If a tool was named (REQ-001) and no install directory/state exists for that tool, the skill reports this and stops, it does not proceed to REQ-002 detection
- If no tool was named and no install directory exists for any supported tool, the skill reports this and stops, rather than asking "which tool" (that question only applies when at least one install exists, see REQ-001)
- The skill's report in either case states plainly that this is an initial-setup scenario, not a refresh, and that `setup.sh`/`setup.ps1` should be run directly instead

## Acceptance Criteria
- [ ] Named tool, no install for that tool: skill reports "no install found for {tool}" and stops before any detection or confirmation step
- [ ] No tool named, zero installs present: skill reports "no Planifest install found" and stops, without asking which tool
- [ ] In both cases, the report directs the human on the loop to `setup.sh`/`setup.ps1` for initial installation

## Dependencies
- REQ-001 (this is the "zero installs" branch of tool detection)
