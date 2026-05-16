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
| `.claude/settings.json` | File (merged) | Hook wiring for PreToolUse, UserPromptSubmit, PostToolUse — additive merge, never full replacement |
| `.claude/hooks/enforcement/` | Directory | `gate-write.mjs`, `check-design.mjs` — always installed |
| `.claude/hooks/context-mode/` | Directory | `block-grep.sh`, `block-bash.sh`, `block-webfetch.sh` — only with `--context-mode-mcp` |
| `.claude/hooks/telemetry/` | Directory | `emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs` — only with both flags |
| `.claude/telemetry-enabled` | Sentinel file | Created when `--structured-telemetry-mcp` is passed; signals telemetry hooks to emit |
| `.claude/skills/` | Directory | Skill files from `planifest-framework/skills/` |
| `CLAUDE.md` | File | Generated from `templates/standard-boot.md` (Claude Code only) |
| `git config core.hooksPath` | Git config | Points to `planifest-framework/hooks/` for advisory commit-msg hook |
| `planifest-framework/external-skills.json` | File | Manifest of installed external skills (created on first `add-skill`) |

## Breaking Change Policy

Changes to `setup.sh` inputs or outputs require a version bump in `component.yml` and a migration note. Consumers: any developer running setup.sh on a Planifest-managed project.

## Consumers

No downstream components consume the outputs programmatically. Outputs are consumed by:
- The AI coding agent at session start (reads `settings.json`, skills, boot file)
- Git at commit time (reads `core.hooksPath`)
- `skill-sync.sh` (reads `external-skills.json`)
