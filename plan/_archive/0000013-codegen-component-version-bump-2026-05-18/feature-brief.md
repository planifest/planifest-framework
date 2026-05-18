---
id: "0000013-codegen-component-version-bump"
title: "Codegen component.yml version bump"
adoption_mode: "retrofit"
---

# Feature Brief — 0000013-codegen-component-version-bump

## Problem Statement

When the codegen-agent (P3) modifies files in `planifest-framework/`, the `planifest-framework/component.yml` version and feature fields are not updated. The ship-agent then creates a git tag from a stale version. Observed in feature 0000012 where the tag was `v0.7.0` instead of `v0.12.0`.

## User Stories

1. As a codegen-agent completing a framework-modifying P3 run, I must update `planifest-framework/component.yml` — bumping the minor version and setting the `feature` field to the current feature ID — so the ship-agent tags the correct version.

## Target Architecture

### Components

| Component | Type | Change |
|-----------|------|--------|
| planifest-codegen-agent | skill | Add component.yml close-out step |

### Stack

| Layer | Choice |
|-------|--------|
| Language | Markdown / SKILL.md |
| Build target | local (no runtime) |

## Phases

| Phase | Features | Ships When |
|-------|----------|-----------|
| 1 | REQ-001 | AC passes; merged with 0000012 |
