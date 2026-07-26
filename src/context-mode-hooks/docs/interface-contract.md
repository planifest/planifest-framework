# Interface Contract — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.2.0
**Breaking Change Policy:** requires-human-approval

> Contract unchanged by the 0000017 `.mjs` port (req-004, ADR-002) — same stdin schema, same stdout decision format, same exit-code semantics. Only the implementation language and invocation (`node <script>`) changed.

---

## Input

Each hook script reads a single JSON object from **stdin**, provided by Claude Code before the tool call executes.

### Schema (Claude Code PreToolUse stdin payload)

```json
{
  "session_id": "<string>",
  "hook_event_name": "PreToolUse",
  "tool_name": "<string>",
  "tool_input": {
    // tool-specific fields — see below
  }
}
```

### Per-hook `tool_input` fields consumed

| Hook | Field | Type | Used For |
|------|-------|------|---------|
| `block-grep.mjs` | `tool_input.pattern` | string | Included in redirect message |
| `block-grep.mjs` | `tool_input.path` | string | Included in redirect message |
| `block-bash.mjs` | `tool_input.command` | string | Allowlist check + pattern match |
| `block-webfetch.mjs` | `tool_input.url` | string | Included in redirect message |

**Defaults:** If any field is absent or null, hooks default to `"PATTERN"`, `"PATH"`, `"COMMAND"`, or `"URL"` respectively — no crash.

---

## Output

Each hook writes a single JSON object to **stdout** and exits 0.

### Schema (Claude Code PreToolUse hookSpecificOutput — current format)

**Deny (block) decision:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "<redirect message>"
  }
}
```

**Allow decision:**
Exit 0 with **no output** (empty stdout).

### Deprecated format (do not use)
The top-level `{"decision": "block", "reason": "..."}` format is deprecated for PreToolUse hooks as of Claude Code Q1 2026. Do not use it. See ADR-001.

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Normal — either deny JSON written to stdout, or empty stdout (allow) |
| non-0 | Hook error — Claude Code may allow the tool call through; treated as hook failure |

Hooks always exit 0. Non-zero exits are prevented by `set -euo pipefail` combined with safe defaults in the JSON extraction path.

---

## Redirect Message Contract

The `permissionDecisionReason` field is the primary communication channel back to the agent. It follows this format:

| Hook | Redirect tools named |
|------|---------------------|
| `block-grep.mjs` | `ctx_execute(language:"shell", code:"grep '<pattern>' <path>")` |
| `block-bash.mjs` (grep/rg) | `ctx_execute(language:"shell", code:"<original command>")` |
| `block-bash.mjs` (curl/wget) | `ctx_fetch_and_index(url:"<url>")` + `ctx_search(queries:["..."])` |
| `block-webfetch.mjs` | `ctx_fetch_and_index(url:"<url>")` + `ctx_search(queries:["..."])` |

---

## Consumers

This component has no programmatic consumers. Its output is consumed by **Claude Code's PreToolUse hook runner**, which surfaces the `permissionDecisionReason` to the agent as a tool-call rejection message.

---

## Breaking Changes

Changes to the output JSON schema (field names, nesting) constitute a breaking change and require:
1. Verification against the current Claude Code hooks documentation
2. Human approval before rollout
3. Update to all three hook scripts and all three test files simultaneously
