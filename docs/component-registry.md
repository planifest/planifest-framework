# Component Registry

**Last updated:** 0000022-orchestrator-redundancy-removal (02 Aug 2026)
**Maintained by:** planifest-docs-agent

---

## Registry

| ID | Name | Type | Domain | Status | Summary | Docs |
|----|------|------|--------|--------|---------|------|
| `context-mode-hooks` | context-mode Enforcement Hook Scripts | component-pack | developer-tooling | active | Blocking PreToolUse hook scripts (`.mjs`, Node-only since v0.2.0 — no `jq`, no Unix-shell requirement) that enforce context-mode routing rules by intercepting Grep, Bash (pattern-matched), and WebFetch tool calls. | [purpose](../src/context-mode-hooks/docs/purpose.md) |
| `setup-hook-integration` | Setup Hook Integration | component-pack | developer-tooling | active | setup.sh/ps1, skill-sync, and hook adapters (copilot, cursor, windsurf, codex) — installs and configures enforcement hooks, telemetry hooks, context-mode hooks, commit standards, and external skill management into any Planifest-managed project. Now also writes a `.planifest-setup-flags` marker recording the flags used at install time (v0.4.0, 0000020). | [purpose](../src/setup-hook-integration/docs/purpose.md) |
| `planifest-framework` | Planifest Framework | component-pack | developer-tooling | active | Core standards, skills, hooks, and setup scripts enforcing the confirmed-design pipeline (v0.22.0: orchestrator de-duplication pass — `planifest-orchestrator/SKILL.md` reduced 10,379 -> 8,592 words (-17.2%) by removing content already fully and correctly stated in a phase skill, workflow, standard, or template, and relocating model-tier/parallelism reference data into a new `standards/agent-dispatch-standards.md`; verified via the regression pack plus an independent fresh-context P4 diff review, which caught and fixed one genuine content-loss finding before ship). | [component.yml](../planifest-framework/component.yml) |

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
