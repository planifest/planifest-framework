---
title: "Requirement: REQ-003 - Product Version Manifest"
summary: "product.yml at project root aggregates a release version across components via versionPolicy."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - Product Version Manifest

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-003
**Priority:** must-have
**Wave:** 0

---

## User Story

As a multi-component project, I have a `product.yml` at the project root with `id`, `name`, `version`, `versionPolicy`, `feature`, and a `components` list with per-component versions, so that a single release version can be derived and tagged across components.

---

## Functional Requirements
- A `product.template.yml` exists in `planifest-framework/templates/` with fields: `id`, `name`, `version`, `versionPolicy`, `feature`, `components` (list of `{id, version}`)
- `versionPolicy` accepts exactly three values: `max-component-version` (release version = highest component version), `explicit` (human sets `version` directly), `external` (version supplied by an external anchor; see external-versioning override)
- The default policy when a `product.yml` is auto-created is `max-component-version`
- A guide comment block in the template explains when `product.yml` applies (2+ components) and when the single-`component.yml` fallback applies

## Acceptance Criteria
- [ ] `product.template.yml` exists with all six fields and documents the three `versionPolicy` values
- [ ] A seeded multi-component fixture derives the correct release version under each of the three policy values
- [ ] Single-component projects require no `product.yml` (fallback documented)

## Dependencies
- None (REQ-004 and REQ-005 consume this manifest)
