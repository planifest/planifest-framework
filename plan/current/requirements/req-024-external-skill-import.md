---
title: "Requirement: REQ-024 - External skill import"
summary: "Agent-driven command to fetch skills from the official Anthropic skills repository and install them into the active plan. setup.sh add-skill is a manual escape hatch only."
status: "draft"
version: "0.2.0"
---
# Requirement: REQ-024 - External skill import

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Priority:** must-have

---

## Functional Requirements

### Primary path — agent-driven

The agent installs external skills by calling `skill-sync.sh` (or `skill-sync.ps1` on Windows) via its Bash tool. The agent is the primary caller in all normal pipeline usage. The human never needs to touch the shell directly.

### Separate sync scripts

Two scripts handle all skill copy/remove operations:

- `planifest-framework/scripts/skill-sync.sh` (macOS/Linux/Git Bash)
- `planifest-framework/scripts/skill-sync.ps1` (Windows PowerShell)

Both expose three operations:

| Operation | Arguments | Effect |
|-----------|-----------|--------|
| `install` | `<skill-name> <tool>` | Copies skill from its storage tier to the tool's skills directory |
| `remove` | `<skill-name> <tool>` | Removes skill from the tool's skills directory |
| `sync` | `<tool>` | Re-installs all manifest entries to the tool's skills directory |

### Storage tiers

Skills are stored in one of two locations depending on their scope (REQ-025):

- **Plan-scoped** (default): `plan/current/external-skills/<skill-name>/` — gitignored, ephemeral
- **Preserved**: `planifest-framework/external-skills/<skill-name>/` — committed, persists across features

`skill-sync.sh install` copies from whichever tier the skill currently resides in.

### Trusted source

The default source is `https://github.com/anthropics/skills/tree/main/skills`. No additional authorisation is required for skills from this source (ADR-009).

For any other source, the agent must present the full source URL to the Human on the Loop and receive explicit confirmation before fetching. The install is aborted without confirmation.

### Manual escape hatch

`setup.sh` and `setup.ps1` expose `add-skill <skill-name> [--from <url>]` subcommands for humans who need to manage skills outside an agent session. These call `skill-sync.sh install` internally.

### On successful install

The skill is recorded in `planifest-framework/external-skills.yml` (REQ-025) with `scope: plan` by default.

### Error handling

- Skill name not found in source: print clear error, exit 1.
- Network fetch fails: print clear error, exit 1.
- Skill already installed: print warning, exit 0 (idempotent).

## Acceptance Criteria

- [ ] Agent can install a skill from the Anthropic repo by calling `skill-sync.sh install`.
- [ ] Non-Anthropic source requires human confirmation before fetching; declined = abort with exit 1.
- [ ] Installed skill appears in `plan/current/external-skills/` and in the tool's skills directory.
- [ ] Manifest entry created with correct `scope: plan`, `source`, `trusted`, `installedAt`, `featureId`.
- [ ] Re-running install on an already-installed skill exits 0 with a warning.
- [ ] `setup.sh add-skill` escape hatch works and delegates to `skill-sync.sh`.
- [ ] `skill-sync.ps1` provides identical operations on Windows.

## Dependencies

- REQ-025 (manifest and two-tier storage must be defined).
- REQ-026 (P0 orchestrator skill discovery triggers the agent-driven install path).
