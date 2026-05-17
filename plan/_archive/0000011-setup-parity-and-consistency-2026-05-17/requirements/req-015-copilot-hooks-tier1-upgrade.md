---
title: "Requirement: REQ-015 - Implement Planifest hooks for GitHub Copilot CLI"
summary: "GitHub Copilot CLI has a native hooks system. Planifest must install hook configuration under .github/hooks/ and wire gate-write (preToolUse) and check-design (userPromptSubmitted) enforcement through the documented hook API."
status: "active"
version: "0.3.0"
---
# Requirement: REQ-015 - Implement Planifest hooks for GitHub Copilot CLI

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** GitHub Copilot hooks documentation — https://docs.github.com/en/copilot/reference/hooks-configuration and https://docs.github.com/en/copilot/concepts/agents/hooks
**Priority:** must-have

---

## User Story

As a developer using GitHub Copilot CLI in a Planifest repo, I want gate-write and check-design enforcement to fire natively through Copilot's hook system so that scope enforcement is automatic and cannot be bypassed by the agent ignoring written instructions.

## Functional Requirements

### Hook events and their Planifest mapping

Per the Copilot hooks reference, two hook events are relevant:

- **`preToolUse`** — fires before each tool call. The adapter must return `{ "permissionDecision": "deny", "permissionDecisionReason": "<reason>" }` as JSON on stdout to block. Exit code 2 is a *warning only* in Copilot (not a block); the JSON output is the correct mechanism for `preToolUse` denial.
- **`userPromptSubmitted`** — fires when the user submits a prompt. Cannot block execution; can inject `{ "additionalContext": "<text>" }` into the session.

### Hook adapter

`planifest-framework/hooks/adapters/copilot.mjs` must:

- Accept both Copilot envelope formats:
  - **camelCase** (event name in lowercase, e.g. `preToolUse`): `{ sessionId, timestamp, cwd, toolName, toolArgs }`
  - **VS Code compatible** (event name in PascalCase, e.g. `PreToolUse`): `{ hook_event_name, session_id, timestamp, cwd, tool_name, tool_input }`
- Dispatch on event name (case-insensitive match for both formats):
  - `preToolUse` / `PreToolUse`: read `toolName ?? tool_name` and `toolArgs ?? tool_input`; if the tool is a write/edit operation, run gate-write logic and return `{ "permissionDecision": "deny", "permissionDecisionReason": "<message>" }` on stdout if blocked; exit 0 in all cases (exit code 2 does not block preToolUse in Copilot)
  - `userPromptSubmitted` / `UserPromptSubmit`: run check-design logic; if context should be injected, write `{ "additionalContext": "<text>" }` to stdout; exit 0
  - Any other event: exit 0 silently
- Read `cwd` from `cwd` field (both formats provide it)

### Hook configuration

`planifest-framework/setup/copilot.sh` must:
- Create `.github/hooks/` directory if absent
- Write `.github/hooks/planifest.json` with the hook configuration:
  ```json
  {
    "version": 1,
    "hooks": {
      "preToolUse": [
        {
          "type": "command",
          "command": "node planifest-framework/hooks/adapters/copilot.mjs"
        }
      ],
      "userPromptSubmitted": [
        {
          "type": "command",
          "command": "node planifest-framework/hooks/adapters/copilot.mjs"
        }
      ]
    }
  }
  ```
- Be idempotent (overwriting the file with the same content is acceptable)

`planifest-framework/setup/copilot.ps1` must perform the same operations on Windows.

`planifest-framework/setup.sh` must dispatch to `setup/copilot.sh` when tool is `copilot`.

`planifest-framework/setup.ps1` must dispatch to `setup/copilot.ps1` when tool is `copilot`.

## Acceptance Criteria

- [ ] The adapter accepts both camelCase and PascalCase Copilot envelope formats
- [ ] `preToolUse` / `PreToolUse` events: when blocked, the adapter writes `{ "permissionDecision": "deny", "permissionDecisionReason": "..." }` to stdout and exits 0
- [ ] `userPromptSubmitted` / `UserPromptSubmit` events: when context is injected, the adapter writes `{ "additionalContext": "..." }` to stdout and exits 0
- [ ] All other events exit 0 silently
- [ ] `setup/copilot.sh` creates `.github/hooks/planifest.json` registering both events
- [ ] `setup/copilot.ps1` creates `.github/hooks/planifest.json` on Windows
- [ ] `setup.sh` dispatches to `setup/copilot.sh` for the copilot tool
- [ ] `setup.ps1` dispatches to `setup/copilot.ps1` for the copilot tool
- [ ] Setup is idempotent

## Dependencies

- None — adapter and setup scripts are written from scratch per the official documentation
