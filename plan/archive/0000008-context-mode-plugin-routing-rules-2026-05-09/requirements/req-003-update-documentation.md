---
title: "Requirement: REQ-003 - Update documentation"
summary: "All live documentation must describe the context-mode plugin as the canonical source of routing rules."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - Update documentation

**Skill:** planifest-spec-agent
**Feature:** 0000008-context-mode-plugin-routing-rules
**Source:** "As a user reading docs, docs accurately describe what the plugin and setup each provide"
**Priority:** must-have

---

## Functional Requirements

- `docs/context-mode.md`: the "What --context-mode-mcp Installs" section must not describe a routing rules file step; it must state routing rules are provided by the plugin's system prompt; the Supported tools table column header must reflect plugin-sourced routing rules
- `planifest-framework/tool-setup-reference.md`: the `--context-mode-mcp` flag description in the Optional Flags table must reference enforcement hooks only; the Claude Code "Creates" section must not list `AGENTS.md (if --context-mode-mcp)`; the Context-Mode Integration section must not contain a "Routing Rules" subsection
- `planifest-framework/getting-started.md`: the Option: Context-Mode description must not reference routing rules or `AGENTS.md`; it must state routing rules are injected by the plugin
- `planifest-framework/templates/standard-boot.md`: the context-mode operational directive must not reference `AGENTS.md`; it must describe using context-mode tools directly
- `.claude/skills/planifest-implementer/assets/templates/standard-boot.md`: same as above
- `.claude/skills/planifest-refactor/assets/templates/standard-boot.md`: same as above
- `.claude/skills/planifest-test-writer/assets/templates/standard-boot.md`: same as above
- `.claude/skills/planifest-validate-agent/assets/templates/standard-boot.md`: same as above
- `CLAUDE.md`: the context-mode operational directive must not reference `AGENTS.md`

## Acceptance Criteria

- [ ] `grep -r "routing rules in \`AGENTS.md\`" planifest-framework/ .claude/ CLAUDE.md` returns empty
- [ ] `grep -r "context-mode-agents" planifest-framework/ .claude/ docs/ CLAUDE.md` returns empty
- [ ] `docs/context-mode.md` contains the phrase "plugin's system prompt" in the install description
- [ ] `planifest-framework/tool-setup-reference.md` Context-Mode Integration section has no "Routing Rules" heading
- [ ] `planifest-framework/getting-started.md` Option: Context-Mode paragraph does not contain "`AGENTS.md`"

## Dependencies

- REQ-001 — template files must be removed before documentation can accurately describe the new state
- REQ-002 — setup scripts must be updated before setup-reference docs can be accurate
