---
title: "Requirement: REQ-024 - External skill import"
summary: "A setup.sh add-skill subcommand that fetches skills from the official Anthropic skills repository and installs them into the active tool's skills directory."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-024 - External skill import

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Priority:** must-have

---

## Functional Requirements

- `setup.sh` gains an `add-skill <skill-name> [--tool <tool>] [--from <url>]` subcommand.
- The default source is `https://github.com/anthropics/skills/tree/main/skills` (the official Anthropic skills repository). No additional authorisation is required for skills from this source.
- For any other source (`--from <url>`), the Human on the Loop must interactively confirm before the skill is fetched and installed. The prompt must display the full source URL and skill name. The install is aborted if the human does not confirm.
- The subcommand fetches the skill's `SKILL.md` and any accompanying `assets/` directory from the source repository using the GitHub raw content URL pattern.
- The skill is installed to the active tool's skills directory (e.g. `.claude/skills/<skill-name>/`). If `--tool` is omitted, the tool is inferred from the first configured tool directory found (`.claude/`, `.cursor/`, etc.).
- On successful install, the skill is recorded in `planifest-framework/external-skills.yml` (REQ-025).

### Error handling

- If the skill name does not exist in the Anthropic repo, print a clear error and exit 1.
- If the network fetch fails, print a clear error and exit 1.
- If the skill is already installed, print a warning and skip (idempotent).

## Acceptance Criteria

- [ ] `setup.sh add-skill webapp-testing` installs the skill from the Anthropic repo without prompting.
- [ ] `setup.sh add-skill my-skill --from https://example.com/skills/my-skill` prompts for human confirmation before installing.
- [ ] Declining the confirmation prompt aborts the install with exit 1.
- [ ] Installed skill appears in the tool's skills directory and in `external-skills.yml`.
- [ ] Re-running the command on an already-installed skill prints a warning and exits 0.

## Dependencies

- REQ-025 (manifest tracking must exist before install records can be written).
- `curl` or equivalent must be available in the environment (already assumed by setup scripts).
