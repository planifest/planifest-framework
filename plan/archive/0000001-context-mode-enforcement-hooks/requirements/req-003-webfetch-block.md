---
title: "Requirement: REQ-003 - WebFetch Blocking Hook"
summary: "PreToolUse hook that intercepts all WebFetch tool calls and returns a block decision with redirect to ctx_fetch_and_index."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-003 - WebFetch Blocking Hook

**Skill:** spec-agent
**Feature:** 0000001-context-mode-enforcement-hooks
**Source:** User story 1 (implicit) + Acceptance Criterion — "Calling WebFetch returns a block decision with redirect to ctx_fetch_and_index"
**Priority:** must-have

---

## Functional Requirements

- A bash script at `planifest-framework/hooks/context-mode/block-webfetch.sh` reads tool invocation JSON from stdin via a `PreToolUse` hook
- The script unconditionally returns a block decision for the `WebFetch` tool — all WebFetch calls are blocked without exception
- The block decision `reason` field names the specific two-step replacement: first `ctx_fetch_and_index(url:"...")` to ingest the URL, then `ctx_search(queries:["..."])` to query the indexed content
- The script extracts the `url` field from the tool input JSON and includes it in the redirect message so the agent can construct the `ctx_fetch_and_index` call directly
- The script outputs valid JSON to stdout using the `hookSpecificOutput` envelope:
  ```json
  {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<redirect message including original URL>"}}
  ```
- The script exits 0 in all cases (do NOT use exit 2 as a block signal)
- Execution completes within the NFR-001 latency budget (< 50ms wall clock)

## Acceptance Criteria

- [ ] Calling `WebFetch` with any URL with context-mode hooks active returns `decision: "block"`
- [ ] The block `reason` explicitly names `ctx_fetch_and_index` as the replacement and includes the original URL
- [ ] The block `reason` also names `ctx_search` as the follow-up query tool
- [ ] Script completes in < 50ms on cold invocation
- [ ] Script produces no output other than the JSON decision on stdout
- [ ] Script does not write to disk, make network calls, or read files outside of what is passed on stdin

## Dependencies

- REQ-004 (setup integration) must wire this script into `settings.json` `PreToolUse` hooks before the script can be invoked
