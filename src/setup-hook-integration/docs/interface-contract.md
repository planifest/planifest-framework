# Interface Contract — setup-hook-integration

## Inputs

| Input | Type | Required | Description |
|---|---|---|---|
| `<tool>` | CLI positional arg | Yes | Target tool: `claude-code`, `cursor`, `windsurf`, `cline`, `codex`, `opencode`, `copilot`, `antigravity`, `roo-code`, `all` |
| `--context-mode-mcp` | CLI flag | No | Install context-mode blocking hooks |
| `--structured-telemetry-mcp` | CLI flag | No | Install telemetry hooks and write `.claude/telemetry-enabled` sentinel |
| `--backend-url <url>` | CLI flag | No | Override default telemetry backend URL (default: `http://localhost:3741`) |
| `add-skill <name> <tool>` | Subcommand | No | Delegate to skill-sync.sh: fetch and install an external skill |
| `remove-skill <name> <tool>` | Subcommand | No | Delegate to skill-sync.sh: remove an installed skill |
| `preserve-skill <name> <tool>` | Subcommand | No | Delegate to skill-sync.sh: promote skill from plan-scoped to preserved |
| `unpreserve-skill <name> <tool>` | Subcommand | No | Delegate to skill-sync.sh: demote skill from preserved to plan-scoped |

## Outputs

| Output | Type | Description |
|---|---|---|
| `.claude/settings.json` | File (merged) | Hook wiring for PreToolUse, UserPromptSubmit, PostToolUse. Additive merge, never full replacement. Every enforcement command string is written with a `node` interpreter prefix (0000028 P5 SEC-001); a bare `.mjs` path exits 126 against the non-executable committed file mode and fails open silently |
| `.claude/hooks/enforcement/` | Directory | Every `*.mjs` under `hooks/enforcement/`, always installed, not gated on any flag. Currently `gate-write.mjs`, `check-design.mjs`, `ratchet-check.mjs`, `em-dash-guard.mjs` (0000028), `auto-trigger-orchestrator.mjs`, `check-orchestrator-presence.mjs`, `check-telemetry-failures.mjs`, `check-telemetry-receipts.mjs`, plus the shared modules `read-stdin.mjs` and `phase-enum.mjs` (0000028) |
| `.claude/hooks/context-mode/` | Directory | `block-grep.mjs`, `block-bash.mjs`, `block-webfetch.mjs`, only with `--context-mode-mcp`. Corrected at 0000028 P6: these became `.mjs` at 0000017 (ADR-002) and this table still named the retired `.sh` form |
| `.claude/hooks/telemetry/` | Directory | Every `*.mjs` under `hooks/telemetry/`, only with `--structured-telemetry-mcp`. Corrected at 0000028 P6: 0000018-ADR-001 removed the `--context-mode-mcp` AND-condition this table still described as "both flags". Currently `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`, `emit-event-receipt.mjs`, `resolve-phase.mjs`, plus the shared modules `emit-event.mjs`, `record-telemetry-failure.mjs`, `read-product-id.mjs`, `get-flag-path.mjs` (0000028). The tier 1 path (Cursor, Windsurf, Cline) copies the same `*.mjs` glob since 0000028; it previously copied only `emit-phase-*.mjs` and would have dropped every shared module |
| `.claude/telemetry-enabled` | Sentinel file | Created when `--structured-telemetry-mcp` is passed; signals telemetry hooks to emit |
| `.claude/skills/` | Directory | Skill files from `planifest-framework/skills/` |
| `CLAUDE.md` | File | Generated from `templates/standard-boot.md` (Claude Code only) |
| `git config core.hooksPath` | Git config | Points to `planifest-framework/hooks/` for advisory commit-msg hook |
| `planifest-framework/external-skills.json` | File | Manifest of installed external skills (created on first `add-skill`) |
| `<tool-dir>/.planifest-setup-flags` | File | Flags-used marker (0000020): tool, flags applied, backend URL, timestamp, attempt status. Written on every successful install; consumed by `planifest-refresh-setup`. Schema: `docs/data-contract.md` |

## Breaking Change Policy

Changes to `setup.sh` inputs or outputs require a version bump in `component.yml` and a migration note. Consumers: any developer running setup.sh on a Planifest-managed project.

## Consumers

No downstream components consume the outputs programmatically. Outputs are consumed by:
- The AI coding agent at session start (reads `settings.json`, skills, boot file)
- Git at commit time (reads `core.hooksPath`)
- `skill-sync.sh` (reads `external-skills.json`)
- `planifest-refresh-setup` skill (reads and updates `.planifest-setup-flags`, 0000020)
