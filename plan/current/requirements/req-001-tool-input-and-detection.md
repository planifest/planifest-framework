---
title: "Requirement: REQ-001 - Tool input and detection"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-001 - Tool input and detection

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-001
**Priority:** must-have

---

## User Story

As a human on the loop maintaining a Planifest install, I name which tool's setup to refresh (or the skill asks me, if the repo has more than one tool installed), so that the skill never has to guess which install I mean.

---

## Functional Requirements
- The skill accepts a tool name as input (matching the tool identifiers `setup.sh`/`setup.ps1` already recognise: `claude-code`, `cursor`, `windsurf`, `cline`, `codex`, `opencode`, `antigravity`, `copilot`, `roo-code`)
- If no tool name is given and exactly one tool's install directory is present in the repo, the skill proceeds with that tool without asking
- If no tool name is given and more than one tool's install directory is present, the skill asks the human on the loop which tool to refresh before doing anything else
- Detecting "which tool's install is present" uses the same directory/env-var signals `setup.sh`/`setup.ps1` already use to distinguish tools (e.g. `.claude/`, `.cursor/`, `.windsurf/`, `.clinerules`, `.agents/` + `OPENAI_*`, `.opencode/`)

## Acceptance Criteria
- [ ] Given a named tool argument, the skill proceeds directly with that tool, no detection question asked
- [ ] Given no tool argument and one install present, the skill proceeds with that tool automatically
- [ ] Given no tool argument and two or more installs present, the skill asks the human on the loop to name one before continuing
- [ ] Given no tool argument and zero installs present, the skill does not ask "which tool" (this is the no-install-found case — see REQ-007)

## Dependencies
- None (first step in the refresh flow)
