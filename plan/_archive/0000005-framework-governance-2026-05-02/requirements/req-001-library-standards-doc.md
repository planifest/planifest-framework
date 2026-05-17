---
title: "Requirement: REQ-001 - library-standards-doc"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-001 - library-standards-doc

**Feature:** 0000005-framework-governance
**Source:** library-standards doc user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- `planifest-framework/standards/library-standards/` must exist as a directory tree with one subdirectory per language: python, javascript/react, javascript/nodejs, typescript, java, csharp, cpp, c, go, rust, php, shell, ruby, swift, kotlin, r, dart, scala, elixir, haskell, fsharp
- Each language subdirectory must contain `prefer-avoid.md` listing preferred and avoided libraries for common concerns (HTTP client, testing, validation, etc.)
- Each language subdirectory must contain `test-frameworks.md` listing preferred test frameworks by test type (unit, integration, contract, E2E, performance/load) — only applicable types listed per language
- `planifest-framework/standards/library-standards/_version-policy.md` must exist at the root of the directory tree defining: target latest stable; exact or tilde pinning; no `^latest`; consult changelog before upgrading; peer dependency range satisfaction
- If `planifest-overrides/` or `planifest-overrides/library-standards/` does not exist, agents skip the override check and use `planifest-framework/standards/library-standards/` directly — no error
- When the directory exists, agents check `planifest-overrides/library-standards/{language}/` first and fall back to `planifest-framework/standards/library-standards/{language}/`
- When an avoided library has no acceptable alternative, agents record the exception in `src/{component-id}/docs/quirks.md` with justification — they do not silently use the avoided library
- P3 fully populates: typescript, javascript/react, javascript/nodejs, python, go, java; remaining 16 languages get stub files with `TODO: populate` note

## Acceptance Criteria

- [ ] Directory tree exists with all 21 language subdirs plus `databases/`
- [ ] Each populated language subdir contains `prefer-avoid.md` and `test-frameworks.md`
- [ ] `_version-policy.md` exists at library-standards root
- [ ] `planifest-overrides/library-standards/` exists with `.gitkeep` only
- [ ] 6 languages fully populated; 16 languages have stub files
- [ ] Agents check `planifest-overrides/library-standards/` first, fall back to `planifest-framework/standards/library-standards/`

## Dependencies

- REQ-004 (codegen-agent wiring) — consumes this directory
- REQ-005 (validate-agent wiring) — consumes this directory
