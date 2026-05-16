---
title: "Requirement: REQ-015 - british-english-rewrite"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-015 - british-english-rewrite

**Feature:** 0000005-framework-governance
**Source:** british english rewrite and migration user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- P3 (codegen pass) must rewrite all prose in `planifest-framework/` to use British English spellings — this includes: all SKILL.md files, all standards docs, all templates, and inline comments in hook .mjs files
- Code identifiers within hook files must not be renamed — only comment text and string literals that are human-readable prose
- The rewrite must not alter any file that is a machine-readable config (JSON, YAML frontmatter values, file paths, variable names)
- `planifest-framework/migrations/0002-british-english.md` handles `plan/` and `docs/` artifacts interactively via the migrator; the P3 direct rewrite handles `planifest-framework/` only

## Acceptance Criteria

- [ ] All SKILL.md files in `planifest-framework/skills/` use British English prose after P3
- [ ] All standards docs in `planifest-framework/standards/` use British English prose after P3
- [ ] All templates in `planifest-framework/templates/` use British English prose after P3
- [ ] No code identifier in any hook .mjs file is renamed by the rewrite
- [ ] `0002-british-english.md` migration handles plan/ and docs/ artifacts

## Dependencies

- REQ-013 (formatting-standards) — defines British English as the target locale
- REQ-014 (migration-infrastructure) — 0002 migration handles plan/ and docs/
