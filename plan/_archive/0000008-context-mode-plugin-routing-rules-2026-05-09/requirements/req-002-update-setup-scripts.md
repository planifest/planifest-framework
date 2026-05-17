---
title: "Requirement: REQ-002 - Update setup scripts"
summary: "setup.sh and setup.ps1 must not copy a routing rules file when --context-mode-mcp is passed."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - Update setup scripts

**Skill:** planifest-spec-agent
**Feature:** 0000008-context-mode-plugin-routing-rules
**Source:** "As a user running setup, the --context-mode-mcp flag no longer writes AGENTS.md routing rules"
**Priority:** must-have

---

## Functional Requirements

- `setup.sh` must not write any routing rules file (e.g. `AGENTS.md`) when `--context-mode-mcp` is passed
- `setup.ps1` must not write any routing rules file when `--context-mode-mcp` is passed
- The `--context-mode-mcp` flag in `setup.sh` help text must describe enforcement hooks only — no mention of routing rules file
- The `--context-mode-mcp` flag in `setup.ps1` help text must describe enforcement hooks only — no mention of routing rules file
- Enforcement hook installation (block-grep.sh, block-bash.sh, block-webfetch.sh, settings.json registration) must continue to work unchanged when `--context-mode-mcp` is passed

## Acceptance Criteria

- [ ] Running `./planifest-framework/setup.sh claude-code --context-mode-mcp` does not create or overwrite `AGENTS.md`
- [ ] Running `.\planifest-framework\setup.ps1 claude-code --context-mode-mcp` does not create or overwrite `AGENTS.md`
- [ ] `.claude/hooks/context-mode/block-grep.sh`, `block-bash.sh`, `block-webfetch.sh` are still present after setup
- [ ] `.claude/settings.json` still registers all three hooks as PreToolUse entries after setup
- [ ] `setup.sh --help` output contains "enforcement hooks" and does not contain "routing rules file"
- [ ] `setup.ps1` help output contains "enforcement hooks" and does not contain "routing rules file"

## Dependencies

- REQ-001 — template files must be removed so setup cannot copy them even if the copy step were accidentally reinstated
