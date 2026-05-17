---
title: "Requirement: REQ-018 - Implement Planifest hooks for Cursor"
summary: "Cursor has a native hooks system. Planifest must install hook configuration at .cursor/hooks.json and wire gate-write (preToolUse) and check-design (beforeSubmitPrompt) enforcement through the documented hook API."
status: "active"
version: "0.2.0"
---
# Requirement: REQ-018 - Implement Planifest hooks for Cursor

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** Cursor hooks documentation — https://cursor.com/docs/hooks
**Priority:** must-have

---

## User Story

As a developer using Cursor in a Planifest repo, I want gate-write to block file writes outside the confirmed design scope and check-design to inject scope context before each prompt so that both enforcements work automatically without relying on written instructions.

## Functional Requirements

### Hook events and their Planifest mapping

Per the Cursor hooks documentation, all hooks receive a common JSON envelope on stdin:

```json
{
  "hook_event_name": "<event>",
  "conversation_id": "<string>",
  "generation_id": "<string>",
  "model": "<string>",
  "cursor_version": "<string>",
  "workspace_roots": ["<path>", ...],
  "user_email": "<string | null>"
}
```

Block mechanism: exit code **2** blocks the action (identical to Claude Code, by Cursor design). JSON output `{ "permission": "deny", "user_message": "<text>" }` is an alternative block response.

Relevant Planifest mappings from the full event list:

- **`preToolUse`** — fires before each tool call. Supports `matcher` regex on `tool_name`. Block with exit 2. → gate-write enforcement
- **`beforeSubmitPrompt`** — fires before the user prompt is processed by the agent. → check-design scope injection

### Hook adapter

`planifest-framework/hooks/adapters/cursor.mjs` must:
- Read the JSON envelope from stdin
- Extract:
  - `hook_event_name` — for dispatch
  - `workspace_roots[0]` — as `cwd`
  - `conversation_id` — as `session_id`
  - Per-event fields (e.g. `tool_name`, `tool_input` for `preToolUse`; `prompt` for `beforeSubmitPrompt`)
- Dispatch on `hook_event_name`:
  - `"preToolUse"`: run gate-write logic using `tool_name` and `tool_input`; exit 2 to block
  - `"beforeSubmitPrompt"`: run check-design logic; write scope context to stdout if present; exit 0 (no block for prompt events)
  - All other events: exit 0 silently

### Hook configuration

`planifest-framework/setup/cursor.sh` must:
- Create `.cursor/` directory if absent
- Write `.cursor/hooks.json` at the project root (workspace-level hooks path per documentation):
  ```json
  {
    "version": 1,
    "hooks": {
      "preToolUse": [
        {
          "command": "node planifest-framework/hooks/adapters/cursor.mjs",
          "matcher": "Write|Edit|apply_patch"
        }
      ],
      "beforeSubmitPrompt": [
        {
          "command": "node planifest-framework/hooks/adapters/cursor.mjs"
        }
      ]
    }
  }
  ```
- Be idempotent

`planifest-framework/setup/cursor.ps1` must write the same `.cursor/hooks.json` on Windows.

`planifest-framework/setup.sh` must dispatch to `setup/cursor.sh` when tool is `cursor`.

`planifest-framework/setup.ps1` must dispatch to `setup/cursor.ps1` when tool is `cursor`.

## Acceptance Criteria

- [ ] The adapter reads `hook_event_name` from stdin JSON for dispatch
- [ ] The adapter reads `workspace_roots[0]` as cwd
- [ ] The adapter reads `conversation_id` as session identifier
- [ ] `preToolUse` events trigger gate-write logic; exit 2 blocks
- [ ] `beforeSubmitPrompt` events trigger check-design logic; scope context written to stdout when applicable; exit 0
- [ ] All other events exit 0 without action
- [ ] `setup/cursor.sh` writes `.cursor/hooks.json` registering `preToolUse` (with matcher) and `beforeSubmitPrompt`
- [ ] `setup/cursor.ps1` writes `.cursor/hooks.json` with the same entries
- [ ] `setup.sh` dispatches to `setup/cursor.sh` for the cursor tool
- [ ] `setup.ps1` dispatches to `setup/cursor.ps1` for the cursor tool
- [ ] Setup is idempotent

## Dependencies

- None — adapter and setup scripts are written from scratch per the official documentation
