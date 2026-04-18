---
title: "Requirement: REQ-011 - Tier 2: OpenCode plugin shim"
summary: "@planifest/opencode-hooks npm plugin bridges OpenCode's JS plugin system to Planifest enforcement scripts."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-011 - Tier 2: OpenCode plugin shim

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-11; DD-005
**Priority:** must-have

---

## Functional Requirements

- An npm package `@planifest/opencode-hooks` is created at `hooks/adapters/opencode/`.
- The package is written in TypeScript/Bun and implements the OpenCode plugin interface.
- On `pre_tool_use` events for Write/Edit tools, the plugin invokes `gate-write.mjs` via `Bun.spawnSync` and propagates the block if exit code is 2.
- On agent start/stop events, the plugin invokes `emit-phase-start.mjs` / `emit-phase-end.mjs`.
- Setup script `setup/opencode.sh` registers the plugin in `opencode.json` under the `plugins` array.
- The plugin uses the Bun runtime (bundled with opencode); no separate Node.js installation required for Tier 2.
- The package includes a `package.json` with `"type": "module"` and a Bun-compatible build config.

## Acceptance Criteria

- [ ] OpenCode blocks a Write when `design.md` is absent; block message appears in OpenCode UI.
- [ ] Telemetry emits `phase_start` via the plugin when an agent session begins.
- [ ] Setup script registers the plugin in `opencode.json` idempotently.
- [ ] Plugin compiles cleanly with `bun build`.
- [ ] No external dependencies beyond what is bundled with OpenCode's Bun runtime.

## Dependencies

- REQ-006, REQ-001 (scripts must be importable/spawnable by the plugin).
- OpenCode plugin API stability — flagged as a risk (R-004).
