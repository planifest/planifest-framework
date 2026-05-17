---
title: "Requirement: REQ-016 - Implement Planifest hooks for Windsurf Cascade"
summary: "Windsurf Cascade has a native hooks system with 12 hook events. Planifest must install hook configuration at .windsurf/hooks.json and wire gate-write (pre_write_code, pre_mcp_tool_use) and check-design (pre_user_prompt) through the documented hook API."
status: "active"
version: "0.2.0"
---
# Requirement: REQ-016 - Implement Planifest hooks for Windsurf Cascade

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** Windsurf Cascade hooks documentation — https://docs.windsurf.com/windsurf/cascade/hooks
**Priority:** must-have

---

## User Story

As a developer using Windsurf Cascade in a Planifest repo, I want gate-write and check-design enforcement to fire natively through Cascade's hook system so that scope enforcement is automatic and not dependent on the agent following written instructions.

## Functional Requirements

### Hook events and their Planifest mapping

Per the Windsurf Cascade hooks documentation, all hooks receive a common input structure on stdin:

```json
{
  "agent_action_name": "<event name>",
  "trajectory_id": "<string>",
  "timestamp": "<ISO 8601>",
  "model_name": "<string>",
  "tool_info": { /* event-specific */ }
}
```

Block mechanism: pre-hooks exit with code **2** to block the action. All other exit codes allow it.

Twelve hook events are available. The relevant Planifest mappings:

- **`pre_write_code`** — fires before Cascade writes a file. Block with exit 2. → gate-write enforcement
- **`pre_mcp_tool_use`** — fires before an MCP tool call. Block with exit 2. → gate-write enforcement for write-type MCP tools
- **`pre_user_prompt`** — fires before a user prompt is processed. Block with exit 2. → check-design scope injection (should inject context; may block if no design present)
- All other events (`post_read_code`, `post_write_code`, `pre_run_command`, `post_run_command`, `post_mcp_tool_use`, `post_cascade_response`, `post_cascade_response_with_transcript`, `pre_read_code`) → no Planifest action; pass through

### Hook adapter

`planifest-framework/hooks/adapters/windsurf.mjs` must:
- Read the JSON envelope from stdin
- Dispatch on `agent_action_name`:
  - `"pre_write_code"`: run gate-write logic; exit 2 to block, exit 0 to allow
  - `"pre_mcp_tool_use"`: inspect `tool_info` for write-type MCP tools; run gate-write if applicable; exit 2 to block
  - `"pre_user_prompt"`: run check-design logic; exit 2 to block if no orchestrator sentinel or design is absent; exit 0 to allow (with any context printed to stdout as user-visible feedback)
  - Any other value: exit 0

### Hook configuration

`planifest-framework/setup/windsurf.sh` must:
- Create `.windsurf/` directory if absent
- Write `.windsurf/hooks.json` at the workspace root (the workspace-level hooks path per documentation):
  ```json
  {
    "hooks": {
      "pre_write_code": [
        {
          "command": "node planifest-framework/hooks/adapters/windsurf.mjs"
        }
      ],
      "pre_mcp_tool_use": [
        {
          "command": "node planifest-framework/hooks/adapters/windsurf.mjs"
        }
      ],
      "pre_user_prompt": [
        {
          "command": "node planifest-framework/hooks/adapters/windsurf.mjs"
        }
      ]
    }
  }
  ```
- Be idempotent

`planifest-framework/setup/windsurf.ps1` must write the same `.windsurf/hooks.json` and additionally supply a `powershell` field alongside `command` in each hook entry for Windows compatibility, per the Windsurf cross-platform behavior specification.

`planifest-framework/setup.sh` must dispatch to `setup/windsurf.sh` when tool is `windsurf`.

`planifest-framework/setup.ps1` must dispatch to `setup/windsurf.ps1` when tool is `windsurf`.

## Acceptance Criteria

- [ ] The adapter reads `agent_action_name` from stdin JSON for dispatch
- [ ] `pre_write_code` events trigger gate-write logic; exit 2 blocks
- [ ] `pre_mcp_tool_use` events trigger gate-write logic for write-type MCP tools; exit 2 blocks
- [ ] `pre_user_prompt` events trigger check-design logic; exit 2 blocks when no design/sentinel is present
- [ ] All other events exit 0 without action
- [ ] `setup/windsurf.sh` writes `.windsurf/hooks.json` registering the three pre-hook events
- [ ] `setup/windsurf.ps1` writes `.windsurf/hooks.json` with both `command` and `powershell` fields
- [ ] `setup.sh` dispatches to `setup/windsurf.sh` for the windsurf tool
- [ ] `setup.ps1` dispatches to `setup/windsurf.ps1` for the windsurf tool
- [ ] Setup is idempotent

## Dependencies

- None — adapter and setup scripts are written from scratch per the official documentation
