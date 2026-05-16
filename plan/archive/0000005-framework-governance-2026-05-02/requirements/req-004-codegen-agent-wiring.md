---
title: "Requirement: REQ-004 - codegen-agent-wiring"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-004 - codegen-agent-wiring

**Feature:** 0000005-framework-governance
**Source:** codegen-agent wiring user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- planifest-codegen-agent SKILL.md must add a pre-scaffold step: before writing any dependency manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, `composer.json`, `pom.xml`, `build.gradle`, `pubspec.yaml`, or equivalent), check `planifest-overrides/library-standards/{language}/prefer-avoid.md` first, then fall back to `planifest-framework/standards/library-standards/{language}/prefer-avoid.md`
- Every dependency in the manifest must be cross-referenced against the avoid list for the declared stack; any match must be substituted with the preferred alternative
- If no non-avoided alternative exists for a requirement, codegen-agent must fail and escalate to the human — it must not silently use the avoided library
- `library-standards.md` (or its directory equivalent) must be added to `bundle_standards` in codegen-agent SKILL.md frontmatter

## Acceptance Criteria

- [ ] codegen-agent SKILL.md contains pre-scaffold step referencing library-standards lookup
- [ ] `library-standards` present in codegen-agent `bundle_standards` frontmatter
- [ ] Codegen-agent substitutes avoided libraries with preferred alternatives
- [ ] Codegen-agent escalates (does not silently proceed) when no alternative exists

## Dependencies

- REQ-001 (library-standards-doc) — requires the directory to exist
