# Purpose — setup-hook-integration

## What this component exists to do

`setup-hook-integration` is the installation layer of the Planifest framework. It bridges the framework source (in `planifest-framework/`) and the tool-specific configuration directories that AI coding agents read at startup.

When a developer runs `setup.sh <tool>`, this component:

1. **Installs enforcement hooks** — copies `gate-write.mjs` and `check-design.mjs` into `.claude/hooks/enforcement/` and wires `PreToolUse` (Write/Edit) and `UserPromptSubmit` entries in `settings.json`.
2. **Installs context-mode hooks** (optional, `--context-mode-mcp`) — copies blocking hook scripts for Grep, Bash, and WebFetch.
3. **Installs telemetry hooks** (optional, `--structured-telemetry-mcp`) — copies `emit-phase-start.mjs`, `emit-phase-end.mjs`, and `context-pressure.mjs`; merges PostToolUse entries.
4. **Installs the advisory commit-msg hook** — registers `planifest-framework/hooks/commit-msg` via `git config core.hooksPath`.
5. **Syncs external skills** — calls `skill-sync.sh sync <tool>` to re-install any skills registered in `external-skills.json`.
6. **Copies skills to the tool's skills directory** — SKILL.md files from `planifest-framework/skills/` copied to `.claude/skills/`, `.cursor/rules/`, etc.
7. **Writes the boot template** — generates `CLAUDE.md`, `AGENTS.md`, etc. from `templates/standard-boot.md`.

It is designed to be re-run safely (idempotent) and is the single entry point for all tool-specific configuration.
