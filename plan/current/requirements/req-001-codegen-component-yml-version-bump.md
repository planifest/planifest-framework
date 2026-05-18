---
id: REQ-001
slug: codegen-component-yml-version-bump
title: Codegen-agent bumps planifest-framework/component.yml at P3 close-out
priority: high
status: open
---

# REQ-001 — Codegen-agent bumps planifest-framework/component.yml at P3 close-out

## User Story

As a codegen-agent completing a framework-modifying P3 run, I update `planifest-framework/component.yml` — minor version bump and feature field set to the current feature ID — so the ship-agent always creates the correct git tag.

## Acceptance Criteria

- [ ] `planifest-codegen-agent/SKILL.md` has a "Framework component.yml close-out" step in its Rules section
- [ ] The step triggers when any file under `planifest-framework/` is modified during P3
- [ ] The step specifies: increment the minor version in `component.yml` (e.g. `0.12.0` → `0.13.0`)
- [ ] The step specifies: set the `feature` field to the current feature ID
- [ ] The step specifies: include `planifest-framework/component.yml` in the P3 commit

## Dependencies

None.
