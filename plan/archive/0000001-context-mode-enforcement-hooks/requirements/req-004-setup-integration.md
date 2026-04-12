---
title: "Requirement: REQ-004 - Setup Integration"
summary: "setup.sh and setup.ps1 changes that copy hook scripts and write settings.json hook wiring when --context-mode-mcp is passed."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-004 - Setup Integration

**Skill:** spec-agent
**Feature:** 0000001-context-mode-enforcement-hooks
**Source:** User story 3 — "As a developer running setup with --context-mode-mcp, enforcement hooks are installed automatically alongside the routing rules file"
**Priority:** must-have

---

## Functional Requirements

- When `setup.sh` or `setup.ps1` is invoked with the `--context-mode-mcp` flag for the `claude-code` tool:
  - Copy hook scripts from `planifest-framework/hooks/context-mode/` to `.claude/hooks/context-mode/` in the target project
  - Write `PreToolUse` hook entries for `Grep`, `Bash`, and `WebFetch` into `.claude/settings.json`
  - Each hook entry specifies the path to the corresponding installed script under `.claude/hooks/context-mode/`
- The existing routing rules file installation (context-mode-agents.md → AGENTS.md) is unchanged — hooks are additive
- When `setup.sh` or `setup.ps1` is invoked **without** the `--context-mode-mcp` flag:
  - Hook scripts are NOT copied
  - Hook entries are NOT written to `settings.json`
  - No cleanup of previously installed hooks is performed (re-running without the flag is not a removal operation)
- The `.claude/hooks/context-mode/` directory is created if it does not exist
- The hook scripts are made executable (`chmod +x`) on Unix after copying
- The `settings.json` hook entries use relative paths anchored at the project root, not absolute paths, so the installation is portable
- The wiring for `claude-code` only — other tools (cursor, windsurf, cline, antigravity) are not wired in this feature

### settings.json hook entry format

Each hook entry must conform to Claude Code's `PreToolUse` hook schema:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Grep",
        "hooks": [{"type": "command", "command": ".claude/hooks/context-mode/block-grep.sh"}]
      },
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": ".claude/hooks/context-mode/block-bash.sh"}]
      },
      {
        "matcher": "WebFetch",
        "hooks": [{"type": "command", "command": ".claude/hooks/context-mode/block-webfetch.sh"}]
      }
    ]
  }
}
```
> Field names confirmed against Claude Code hooks documentation. `matcher` = tool name string. `type: "command"`. `command` = script path. An optional `if` field can pre-filter within a matcher group to avoid unnecessary script spawns.

## Acceptance Criteria

- [ ] Running `setup.sh claude-code --context-mode-mcp` copies 3 hook scripts to `.claude/hooks/context-mode/`
- [ ] Running `setup.sh claude-code --context-mode-mcp` writes 3 `PreToolUse` entries into `.claude/settings.json`
- [ ] Running `setup.sh claude-code` (without flag) copies no hook scripts and writes no hook entries
- [ ] Running `setup.ps1 claude-code --context-mode-mcp` produces the same result as the bash equivalent
- [ ] Hook scripts in `.claude/hooks/context-mode/` are executable after installation on Unix
- [ ] Hook paths in `settings.json` are relative (not absolute), verified by checking the written value does not start with `/` or a drive letter
- [ ] Existing `settings.json` content is preserved — the hook entries are merged, not the entire file replaced

## Dependencies

- REQ-001, REQ-002, REQ-003: hook scripts must exist in `planifest-framework/hooks/context-mode/` before setup can copy them
