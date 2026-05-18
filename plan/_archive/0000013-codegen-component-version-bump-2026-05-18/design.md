---
feature_id: "0000013-codegen-component-version-bump"
adoption_mode: "retrofit"
date_confirmed: "2026-05-18"
continuous_run: true
---

# Confirmed Design — 0000013-codegen-component-version-bump

## Problem Statement

P3 (codegen-agent) modifies files in `planifest-framework/` but does not update `planifest-framework/component.yml`. The version and feature fields become stale, causing the ship-agent to create git tags from the wrong version.

## User Stories

1. As a codegen-agent completing a framework-modifying P3 run, I update `planifest-framework/component.yml` — minor version bump and feature field set to the current feature ID — before committing, so the ship-agent always tags the correct version.

## Scope

**In:** Add a close-out step to `planifest-codegen-agent/SKILL.md` that bumps `planifest-framework/component.yml` when P3 modifies any file under `planifest-framework/`.

**Out:** Bumping `src/` component manifests (already covered). Automatic version calculation from git tags.

**Deferred:** Nothing.

## Stack

| Layer | Choice |
|-------|--------|
| Language | Markdown / SKILL.md |
| Build target | local (no runtime) |
| Target file | `planifest-framework/skills/planifest-codegen-agent/SKILL.md` |

## NFRs

| NFR | Target |
|-----|--------|
| Framework component.yml accuracy | Always reflects current feature and version after P3 |

## Repo Instructions

local-git-only: no push, no PR creation by agent.

## Skill Map

| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 | planifest-codegen-agent | Single SKILL.md edit to codegen-agent rules |
