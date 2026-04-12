---
title: "Requirement: REQ-001 - Grep Blocking Hook"
summary: "PreToolUse hook that intercepts all Grep tool calls and returns a block decision with redirect to ctx_execute shell."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-001 - Grep Blocking Hook

**Skill:** spec-agent
**Feature:** 0000001-context-mode-enforcement-hooks
**Source:** User story 1 — "As an agent with context-mode configured, when I call Grep, I receive a block with a specific redirect instruction"
**Priority:** must-have

---

## Functional Requirements

- A bash script at `planifest-framework/hooks/context-mode/block-grep.sh` reads tool invocation JSON from stdin via a `PreToolUse` hook
- The script unconditionally returns a block decision for the `Grep` tool — no pattern matching required; all Grep calls are blocked
- The block decision `reason` field names the specific replacement: `ctx_execute(language:"shell", code:"grep ...")`
- The script extracts the `pattern` and `path` fields from the tool input JSON and includes them in the redirect message so the agent can reconstruct the equivalent `ctx_execute` call
- The script outputs valid JSON to stdout using the `hookSpecificOutput` envelope:
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<redirect message>"}}
  ```
- The script exits with code 0 (non-zero is a hard error, not a block signal; do NOT use exit 2 as the block mechanism)
- Execution completes within the NFR-001 latency budget (< 50ms wall clock)

## Acceptance Criteria

- [ ] Calling the `Grep` tool with context-mode hooks active returns `decision: "block"` in the hook output
- [ ] The block `reason` explicitly names `ctx_execute(language:"shell", code:"grep ...")` as the replacement
- [ ] The script completes in < 50ms on a cold invocation (no warm-up assumed)
- [ ] The script produces no output other than the JSON decision on stdout
- [ ] The script does not write to disk, make network calls, or read files outside of what is passed on stdin

## Dependencies

- REQ-004 (setup integration) must wire this script into `settings.json` `PreToolUse` hooks before the script can be invoked
