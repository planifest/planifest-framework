# Component Registry

**Last updated:** 0000016-pipeline-governance-and-loop-engineering (11 Jul 2026)
**Maintained by:** planifest-docs-agent

---

## Registry

| ID | Name | Type | Domain | Status | Summary | Docs |
|----|------|------|--------|--------|---------|------|
| `context-mode-hooks` | context-mode Enforcement Hook Scripts | component-pack | developer-tooling | active | Blocking PreToolUse hook scripts that enforce context-mode routing rules by intercepting Grep, Bash (pattern-matched), and WebFetch tool calls. | [purpose](../src/context-mode-hooks/docs/purpose.md) |
| `setup-hook-integration` | Setup Hook Integration | component-pack | developer-tooling | active | setup.sh/ps1, skill-sync, and hook adapters (copilot, cursor, windsurf, codex) — installs and configures enforcement hooks, telemetry hooks, context-mode hooks, commit standards, and external skill management into any Planifest-managed project. | [purpose](../src/setup-hook-integration/docs/purpose.md) |
| `planifest-framework` | Planifest Framework | component-pack | developer-tooling | active | Core standards, skills, hooks, and setup scripts enforcing the confirmed-design pipeline (v0.16.0: adds backlog convention, product.yml versioning, loop-runner/critic/assessor/verify skills, ratchet-check hook, governed reversal protocol). | [component.yml](../planifest-framework/component.yml) |

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
