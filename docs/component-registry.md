# Component Registry

**Last updated:** 0000020-setup-refresh-skill (01 Aug 2026)
**Maintained by:** planifest-docs-agent

---

## Registry

| ID | Name | Type | Domain | Status | Summary | Docs |
|----|------|------|--------|--------|---------|------|
| `context-mode-hooks` | context-mode Enforcement Hook Scripts | component-pack | developer-tooling | active | Blocking PreToolUse hook scripts (`.mjs`, Node-only since v0.2.0 — no `jq`, no Unix-shell requirement) that enforce context-mode routing rules by intercepting Grep, Bash (pattern-matched), and WebFetch tool calls. | [purpose](../src/context-mode-hooks/docs/purpose.md) |
| `setup-hook-integration` | Setup Hook Integration | component-pack | developer-tooling | active | setup.sh/ps1, skill-sync, and hook adapters (copilot, cursor, windsurf, codex) — installs and configures enforcement hooks, telemetry hooks, context-mode hooks, commit standards, and external skill management into any Planifest-managed project. Now also writes a `.planifest-setup-flags` marker recording the flags used at install time (v0.4.0, 0000020). | [purpose](../src/setup-hook-integration/docs/purpose.md) |
| `planifest-framework` | Planifest Framework | component-pack | developer-tooling | active | Core standards, skills, hooks, and setup scripts enforcing the confirmed-design pipeline (v0.20.0: added `planifest-refresh-setup`, a standalone skill that detects a Planifest install's target tool, reconstructs the setup flags currently in effect from hook wiring and the flags-used marker, confirms with the human on the loop, and safely re-invokes setup, closing the manual-reconstruction gap identified in backlog 0000013; boot-file deletion is enforced by a new hardcoded script, `refresh-delete-boot-files.sh`/`.ps1`, not by prompt instructions alone, per a P5 security finding). | [component.yml](../planifest-framework/component.yml) |

---

## Status Key

| Status | Meaning |
|--------|---------|
| `active` | In production / installed in target environments |
| `in-progress` | Pipeline in flight |
| `deprecated` | Superseded; pending removal |
| `planned` | On roadmap; not yet in a pipeline |

---

## Notes

- This registry is updated by the docs-agent at the end of each feature pipeline.
- Each `ID` corresponds to a directory under `src/` containing a `component.yml` manifest.
- Add new components here when a new feature pipeline completes Phase 6.
