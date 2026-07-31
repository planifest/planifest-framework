---
title: "Requirement: req-001 - remove-context-mode-mcp-coupling"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-001 - remove-context-mode-mcp-coupling

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000018-telemetry-emission-consistency
**Source:** US-001
**Priority:** must-have

---

## User Story

As a human running a Planifest pipeline with telemetry enabled, I see every event the phase skills specify actually emitted during the run, so that the collected data reflects real pipeline behavior, not whatever an agent happened to remember.

---

## Functional Requirements
- Remove the `--context-mode-mcp` AND-condition from telemetry hook installation in `setup.sh` — `install_telemetry_hooks` must fire whenever `STRUCTURED_TELEMETRY_MCP=true` alone, no longer requiring `CONTEXT_MODE_MCP=true` as well
- Apply the equivalent fix to `setup.ps1`'s telemetry hook installation gating
- Verify no other hidden dependency on context-mode-mcp being active exists in the installer path (shared directories, shared settings.json sections, etc.) before removing the coupling

## Acceptance Criteria
- [ ] `setup.sh claude-code --structured-telemetry-mcp` (without `--context-mode-mcp`) installs and wires the telemetry hooks, with the backend URL correctly embedded in the hook command
- [ ] `setup.ps1` mirrors this behavior for the equivalent flag
- [ ] Existing behavior is unchanged when both flags are passed together (no regression)
- [ ] No installer-path dependency on context-mode-mcp being active is broken by the decoupling

## Dependencies
- None — self-contained installer logic change
