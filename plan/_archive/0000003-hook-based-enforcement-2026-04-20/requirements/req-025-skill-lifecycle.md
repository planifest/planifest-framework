---
title: "Requirement: REQ-025 - External skill manifest and lifecycle"
summary: "Two-tier storage for external skills. Plan-scoped skills live under plan/current/ and are removed at P7. Preserved skills live in planifest-framework/ and persist across features. Single manifest tracks both."
status: "done"
version: "0.2.0"
---
# Requirement: REQ-025 - External skill manifest and lifecycle

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Priority:** must-have

---

## Functional Requirements

### Two-tier storage

| Tier | Path | Committed? | Survives P7? |
|------|------|-----------|--------------|
| Plan-scoped | `plan/current/external-skills/<name>/` | No (gitignored) | No |
| Preserved | `planifest-framework/external-skills/<name>/` | Yes | Yes |

Skills are installed as plan-scoped by default. Preserving a skill moves it from `plan/current/external-skills/` to `planifest-framework/external-skills/` and updates its manifest entry.

### Central manifest

A single manifest at `planifest-framework/external-skills.yml` tracks all external skills across both tiers:

```yaml
skills:
  - name: webapp-testing
    source: https://github.com/anthropics/skills/tree/main/skills/webapp-testing
    trusted: true
    installedAt: "2026-04-20"
    scope: preserved          # lives in planifest-framework/external-skills/
  - name: some-temp-skill
    source: https://github.com/anthropics/skills/tree/main/skills/some-temp-skill
    trusted: true
    installedAt: "2026-04-20"
    featureId: "0000003"
    scope: plan               # lives in plan/current/external-skills/
```

The manifest is created on first install if it does not exist. It is committed to the repository.

### P7 auto-cleanup

During the P7 archive step, the ship-agent:

1. Reads `planifest-framework/external-skills.yml`.
2. Lists all `scope: plan` skills to the Human on the Loop.
3. Asks the human which (if any) should be preserved before removal.
4. For each skill confirmed for preservation: moves skill files from `plan/current/external-skills/<name>/` to `planifest-framework/external-skills/<name>/`, updates `scope` to `preserved` in the manifest.
5. Removes all remaining `scope: plan` skill directories from `plan/current/external-skills/` and deletes their manifest entries.
6. Calls `skill-sync.sh remove <name> <tool>` for each removed skill to clean up the tool's skills directory.
7. If no preserved skills remain after cleanup, removes the manifest file.

### Remove (on-demand)

The agent removes a skill on human request by calling `skill-sync.sh remove <name> <tool>` and deleting the manifest entry and skill directory.

### sync on setup re-run

When `setup.sh` is re-run, it calls `skill-sync.sh sync <tool>` which re-installs all manifest entries to the tool's skills directory (re-fetching any plan-scoped skill files absent from `plan/current/external-skills/`).

## Acceptance Criteria

- [ ] `planifest-framework/external-skills.yml` created on first install with correct fields.
- [ ] Plan-scoped skills stored under `plan/current/external-skills/` (gitignored).
- [ ] Preserved skills stored under `planifest-framework/external-skills/` (committed).
- [ ] P7 ship-agent lists `scope: plan` skills and prompts for preservation before removal.
- [ ] Preserving a skill moves files to `planifest-framework/external-skills/` and updates manifest.
- [ ] Removed skills disappear from both the manifest and the tool's skills directory.
- [ ] `skill-sync.sh sync` restores skills from manifest on setup re-run.
- [ ] Empty manifest is removed after final cleanup.

## Dependencies

- REQ-024 (`add-skill` writes manifest entries this requirement manages).
- REQ-019 (ship-agent P7 archive step must be extended to invoke cleanup).
- `plan/current/external-skills/` must be added to `.gitignore`.
