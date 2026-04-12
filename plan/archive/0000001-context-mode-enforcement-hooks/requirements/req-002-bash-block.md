---
title: "Requirement: REQ-002 - Bash Pattern Blocking Hook"
summary: "PreToolUse hook that intercepts Bash tool calls matching blocked command patterns and returns a block decision with the correct sandbox alternative."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-002 - Bash Pattern Blocking Hook

**Skill:** spec-agent
**Feature:** 0000001-context-mode-enforcement-hooks
**Source:** User story 2 — "As an agent with context-mode configured, when I call Bash with a blocked pattern, I receive a block with the correct sandbox alternative"
**Priority:** must-have

---

## Functional Requirements

- A bash script at `planifest-framework/hooks/context-mode/block-bash.sh` reads the Bash tool invocation JSON from stdin
- The script extracts the `command` field from the tool input JSON
- The script applies pattern matching against the command string using the following blocked patterns:
  - `grep` (standalone or as part of a pipeline)
  - `rg` (ripgrep — standalone or as part of a pipeline)
  - `curl` (any invocation)
  - `wget` (any invocation)
  - Inline HTTP calls: any command containing `http://` or `https://` that is not an allowlisted tool
- The script applies an **allowlist** before any blocked-pattern check. Commands that begin with any of the following tokens are NEVER blocked regardless of other content:
  - `git`
  - `mkdir`
  - `rm`
  - `mv`
  - `cd`
  - `ls`
  - `npm install`
  - `pip install`
- If the command matches a blocked pattern (and is not allowlisted), the script returns a deny decision naming the specific `ctx_*` replacement:
  - `grep` / `rg` patterns → redirect to `ctx_execute(language:"shell", code:"grep ...")`
  - `curl` / `wget` / HTTP patterns → redirect to `ctx_fetch_and_index` + `ctx_search`
- Block output format:
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<redirect message including original command>"}}
  ```
- If the command does not match any blocked pattern, the script exits 0 with no output (allow by default)
- The script exits 0 in all cases (exit 2 is a hard error that bypasses JSON — do NOT use it)
- Execution completes within the NFR-001 latency budget (< 50ms wall clock)

## Acceptance Criteria

- [ ] Bash call with `grep pattern path` → block, reason names `ctx_execute(language:"shell", code:"grep ...")`
- [ ] Bash call with `rg pattern` → block, reason names `ctx_execute(language:"shell", code:"rg ...")`
- [ ] Bash call with `curl https://...` → block, reason names `ctx_fetch_and_index` + `ctx_search`
- [ ] Bash call with `wget https://...` → block, reason names `ctx_fetch_and_index` + `ctx_search`
- [ ] Bash call with `git status` → allow (not blocked)
- [ ] Bash call with `mkdir src/foo` → allow (not blocked)
- [ ] Bash call with `npm install` → allow (not blocked)
- [ ] Bash call with `git log --oneline | grep feat` → allow (git is the leading command; grep in a pipe is not blocked)
- [ ] Script completes in < 50ms on cold invocation
- [ ] Script produces no output other than the JSON decision on stdout

## Dependencies

- REQ-004 (setup integration) must wire this script into `settings.json` `PreToolUse` hooks
