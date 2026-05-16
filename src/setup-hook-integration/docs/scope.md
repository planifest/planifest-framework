# Scope — setup-hook-integration

## In Scope

- `setup.sh` and `setup.ps1` — all flag processing and tool dispatch
- `setup/<tool>.sh` and `setup/<tool>.ps1` — per-tool configuration stubs
- `planifest-framework/hooks/` — all hook scripts installed by setup
- `planifest-framework/scripts/skill-sync.sh` and `skill-sync.ps1` — external skill lifecycle management
- `planifest-framework/standards/commit-standards.md` — normative commit message rules
- `planifest-framework/templates/standard-boot.md` — source template for generated boot files
- `external-skills.json` manifest — records installed external skills
- Claude Code, Cursor, Windsurf, Cline, Codex, OpenCode, Copilot, Antigravity, Roo Code tool targets

## Out of Scope

- The content of individual skill SKILL.md files (owned by each skill)
- MCP server configuration — user's responsibility
- Hook uninstall / removal logic — not implemented in v1
- Automated rollback on failed setup — not implemented
- Skill content validation beyond YAML frontmatter presence

## Deferred

- `setup.ps1` skill subcommand routing (TD-006) — add in next iteration
- `validate_skill_name()` security guard (TD-001/002/003) — add via change-agent
- Automated test coverage for `skill-sync.sh` operations — future iteration
