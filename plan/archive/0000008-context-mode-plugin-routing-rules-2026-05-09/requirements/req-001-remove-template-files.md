---
title: "Requirement: REQ-001 - Remove context-mode-agents.md template files"
summary: "All context-mode-agents.md files must be deleted from the repository."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-001 - Remove context-mode-agents.md template files

**Skill:** planifest-spec-agent
**Feature:** 0000008-context-mode-plugin-routing-rules
**Source:** "As a maintainer, I no longer maintain two copies of routing rules"
**Priority:** must-have

---

## Functional Requirements

- The file `planifest-framework/templates/context-mode-agents.md` must not exist
- The file `.claude/skills/planifest-implementer/assets/templates/context-mode-agents.md` must not exist
- The file `.claude/skills/planifest-refactor/assets/templates/context-mode-agents.md` must not exist
- The file `.claude/skills/planifest-test-writer/assets/templates/context-mode-agents.md` must not exist
- The file `.claude/skills/planifest-validate-agent/assets/templates/context-mode-agents.md` must not exist
- No new `context-mode-agents.md` file may be introduced by any setup script or skill

## Acceptance Criteria

- [ ] `find . -name 'context-mode-agents.md' -not -path '*/worktrees/*' -not -path '*/.git/*'` returns empty
- [ ] No skill's `bundle_templates` frontmatter references `context-mode-agents.md`

## Dependencies

- None — this requirement is self-contained
