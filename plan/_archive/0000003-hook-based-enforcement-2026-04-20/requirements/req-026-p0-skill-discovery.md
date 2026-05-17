---
title: "Requirement: REQ-026 - P0 skill discovery"
summary: "The orchestrator's P0 Opening Briefing includes a skill discovery step: the agent checks available Anthropic skills relevant to the feature and offers them to the human before planning begins."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-026 - P0 skill discovery

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Priority:** must-have

---

## Functional Requirements

- The orchestrator's P0 Opening Briefing gains a **Skill Discovery** step, executed after the phase table is displayed and before gap-filling questions begin.
- The agent checks `planifest-framework/external-skills.yml` for already-installed skills and lists any currently active.
- The agent presents the human with a curated list of Anthropic skills relevant to the feature type (inferred from the feature brief). For example:
  - Document-generation features → `docx`, `pdf`, `xlsx`
  - Web application features → `webapp-testing`
  - MCP server features → `mcp-builder`
- The human may: accept one or more, decline all, or request a skill not on the list.
- For each accepted Anthropic skill, the agent calls `skill-sync.sh install <name> <tool>` and confirms installation to the human.
- For a non-Anthropic skill requested by the human, the agent presents the source URL and requires explicit human confirmation before installing (ADR-009).
- The step is skipped silently if `skill-sync.sh` is not present (graceful degradation — setups that haven't run the scripts yet are unaffected).
- The orchestrator SKILL.md is updated to document this step under the Opening Briefing section.

## Acceptance Criteria

- [ ] P0 Opening Briefing includes a skill discovery step with relevant skill suggestions.
- [ ] Accepted skills are installed via `skill-sync.sh` and confirmed to the human.
- [ ] Non-Anthropic skills require human confirmation of source URL before install.
- [ ] Already-installed skills are listed as active, not re-offered.
- [ ] Step is skipped silently when `skill-sync.sh` is absent.
- [ ] Orchestrator SKILL.md documents the skill discovery step.

## Dependencies

- REQ-024 (`skill-sync.sh install` must exist).
- REQ-025 (manifest must be readable to identify already-installed skills).
- REQ-020 (orchestrator SKILL.md update — this requirement extends it).
