---
title: "Requirement: REQ-019 - Implement Planifest hooks for OpenAI Codex CLI"
summary: "Codex CLI has a native hooks system. Planifest must install hook configuration at .codex/hooks.json and wire gate-write (PreToolUse) and check-design (UserPromptSubmit) enforcement through the documented hook API."
status: "active"
version: "0.2.0"
---
# Requirement: REQ-019 - Implement Planifest hooks for OpenAI Codex CLI

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** Codex CLI hooks documentation — https://developers.openai.com/codex/hooks
**Priority:** must-have

---

## User Story

As a developer using Codex CLI in a Planifest repo, I want gate-write to block file writes outside the confirmed design scope and check-design to inject scope context before each prompt so that both enforcements work automatically.

## Functional Requirements

### Hook events and their Planifest mapping

Per the Codex CLI hooks documentation, all hooks receive a common JSON envelope on stdin:

```json
{
  "hook_event_name": "<event>",
  "session_id": "<string>",
  "transcript_path": "<string | null>",
  "cwd": "<string>",
  "model": "<string>",
  "permission_mode": "default | acceptEdits | plan | dontAsk | bypassPermissions"
}
```

Turn-scoped events (`PreToolUse`, `PermissionRequest`, `PostToolUse`) also include `turn_id`.

Relevant Planifest mappings:

- **`PreToolUse`** — fires before each tool call. Supports `matcher` regex on `tool_name`. Additional fields: `{ turn_id, tool_name, tool_use_id, tool_input }`. Block by writing this JSON to stdout (exit code alone is insufficient for PreToolUse):
  ```json
  {
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": "<reason>"
    }
  }
  ```
  → gate-write enforcement

- **`UserPromptSubmit`** — fires when the user submits a prompt. Common output fields: `{ "systemMessage": "<text>" }` to inject context into the session. Exit 0 in all cases (no blocking).
  → check-design scope injection

### Hook adapter

`planifest-framework/hooks/adapters/codex.mjs` must:
- Exit 0 silently on Windows (`platform() === "win32"`) — Codex CLI hooks are macOS/Linux only
- Read the JSON envelope from stdin
- Extract:
  - `hook_event_name` — for dispatch
  - `session_id` — as session identifier
  - `cwd` — as working directory
  - Per-event fields: `tool_name` and `tool_input` for `PreToolUse`
- Dispatch on `hook_event_name`:
  - `"PreToolUse"`: run gate-write logic using `tool_name` and `tool_input`; if blocked, write the deny `hookSpecificOutput` JSON to stdout and exit 0 (Codex reads the JSON; do not rely on exit code for PreToolUse blocks)
  - `"UserPromptSubmit"`: run check-design logic; if context is available, write `{ "systemMessage": "<text>" }` to stdout; exit 0
  - `"SessionStart"`, `"PostToolUse"`, `"PermissionRequest"`, `"Stop"`: exit 0 silently
  - Any unrecognised event: exit 0 silently

### Hook configuration

`planifest-framework/setup/codex.sh` must:
- Create `.codex/` directory if absent
- Write `.codex/hooks.json` at the project root:
  ```json
  {
    "hooks": {
      "PreToolUse": [
        {
          "matcher": "apply_patch|Edit|Write",
          "hooks": [
            {
              "type": "command",
              "command": "node .agents/hooks/adapters/codex.mjs",
              "statusMessage": "Checking Planifest scope"
            }
          ]
        }
      ],
      "UserPromptSubmit": [
        {
          "hooks": [
            {
              "type": "command",
              "command": "node .agents/hooks/adapters/codex.mjs",
              "statusMessage": "Injecting Planifest scope context"
            }
          ]
        }
      ]
    }
  }
  ```
- Be idempotent
- Note: Codex discovers hooks at `<repo>/.codex/hooks.json`; the adapter is installed to `.agents/hooks/adapters/codex.mjs` (the Codex skill directory)

`planifest-framework/setup/codex.ps1` must produce the same `.codex/hooks.json` (the file is still written; the adapter exits 0 silently on Windows).

`planifest-framework/setup.sh` must dispatch to `setup/codex.sh` when tool is `codex`.

`planifest-framework/setup.ps1` must dispatch to `setup/codex.ps1` when tool is `codex`.

## Acceptance Criteria

- [ ] The adapter exits 0 silently on Windows
- [ ] The adapter reads `hook_event_name` from stdin JSON for dispatch
- [ ] The adapter reads `session_id` and `cwd` from the common envelope
- [ ] `PreToolUse` events trigger gate-write logic using `tool_name` and `tool_input`
- [ ] When gate-write blocks, the adapter writes `{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "..." } }` to stdout and exits 0
- [ ] `UserPromptSubmit` events trigger check-design logic; writes `{ "systemMessage": "..." }` to stdout when context is available; exits 0
- [ ] All other events exit 0 without action
- [ ] `setup/codex.sh` writes `.codex/hooks.json` registering `PreToolUse` (with matcher) and `UserPromptSubmit`
- [ ] `setup/codex.ps1` writes `.codex/hooks.json` with the same content
- [ ] `setup.sh` dispatches to `setup/codex.sh` for the codex tool
- [ ] `setup.ps1` dispatches to `setup/codex.ps1` for the codex tool
- [ ] Setup is idempotent

## Dependencies

- None — adapter and setup scripts are written from scratch per the official documentation
