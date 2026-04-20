---
title: "Requirement: REQ-010 - Tier 1b: Codex CLI hooks with documented Bash-only limitation"
summary: "Codex CLI hook support activated via features.codex_hooks flag; Bash-only interception documented."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-010 - Tier 1b: Codex CLI hooks with Bash-only limitation

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-10; DD-005
**Priority:** must-have

---

## Functional Requirements

- Adapter `hooks/adapters/codex.mjs` translates the Codex CLI hook envelope to the common Planifest envelope.
- Setup script `setup/codex-cli.sh` appends `features.codex_hooks = true` to `.codex/config.toml` (or creates it) to activate Codex hooks.
- Setup script also registers the adapter as the hook handler for `pre_tool_use` events.
- The setup script prints a documented warning: `[Planifest] Note: Codex CLI hooks are Bash-only. Write interception works in shell environments. Windows is not supported.`
- Telemetry emission (`emit-phase-start.mjs`, `emit-phase-end.mjs`) works via Codex hooks on supported platforms.
- Write-gate blocking via `gate-write.mjs` is supported when invoked from Bash; Windows support is explicitly out of scope.

## Acceptance Criteria

- [ ] Codex CLI setup script activates `features.codex_hooks = true`.
- [ ] Telemetry hooks fire via Codex adapter on macOS/Linux.
- [ ] `gate-write.mjs` can be invoked from the Codex adapter and its exit code propagates correctly.
- [ ] Setup script prints the Bash-only + Windows limitation warning.
- [ ] Setup script is idempotent (re-run safe, does not duplicate config entries).

## Dependencies

- REQ-006 (`gate-write.mjs`), REQ-001 (`emit-phase-start.mjs`).
- Codex CLI `features.codex_hooks` feature flag must be present in the installed Codex version.
