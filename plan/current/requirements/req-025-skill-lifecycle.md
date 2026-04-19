---
title: "Requirement: REQ-025 - External skill manifest and lifecycle"
summary: "External skills are tracked in a manifest and auto-removed at P7 archive unless the human opts to preserve them."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-025 - External skill manifest and lifecycle

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Priority:** must-have

---

## Functional Requirements

### Manifest

- A manifest file is maintained at `planifest-framework/external-skills.yml`.
- Each entry records: `name`, `source` (URL), `trusted` (bool — true for Anthropic repo), `installedAt` (ISO 8601 date), `featureId` (active plan's feature ID at time of install), `preserve` (bool, default false).
- The manifest is created on first `add-skill` call if it does not exist.

### Remove command

- `setup.sh remove-skill <skill-name>` removes the skill from the tool's skills directory and deletes its entry from the manifest.
- If the skill is not installed, print a warning and exit 0 (idempotent).

### Lifecycle — auto-cleanup at P7

- The `planifest-ship-agent` (P7) reads `planifest-framework/external-skills.yml` during the archive step.
- Any skill with `preserve: false` is removed from the tool's skills directory and its entry is deleted from the manifest.
- Before removing, the ship-agent lists the skills to be removed and asks the Human on the Loop whether any should be preserved. For each skill confirmed for preservation, `preserve` is set to `true` and it is not removed.
- After cleanup, if the manifest is empty, the file is removed.

### Preserve command

- `setup.sh preserve-skill <skill-name>` sets `preserve: true` on a manifest entry, protecting it from P7 auto-cleanup.
- `setup.sh unpreserve-skill <skill-name>` resets `preserve: false`.

## Acceptance Criteria

- [ ] `planifest-framework/external-skills.yml` is created on first `add-skill` and contains the correct fields.
- [ ] `setup.sh remove-skill <skill-name>` removes the skill directory and manifest entry.
- [ ] P7 auto-cleanup removes all `preserve: false` skills and prompts before doing so.
- [ ] `setup.sh preserve-skill <skill-name>` prevents P7 removal.
- [ ] Empty manifest file is removed after final cleanup.

## Dependencies

- REQ-024 (`add-skill` command writes the manifest entries this requirement manages).
- `planifest-ship-agent` P7 archive step (REQ-019) must be extended to invoke cleanup.
