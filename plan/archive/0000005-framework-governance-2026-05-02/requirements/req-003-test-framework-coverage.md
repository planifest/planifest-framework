---
title: "Requirement: REQ-003 - test-framework-coverage"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-003 - test-framework-coverage

**Feature:** 0000005-framework-governance
**Source:** test framework coverage user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- Each language's `test-frameworks.md` lists the preferred framework per test type; applicable types per language: unit, integration, contract, E2E, performance/load — not all types apply to every language, omit inapplicable types
- `test-frameworks.md` covers *which* framework to use; `testing-standards.md` covers *how* to write tests — library-standards must not duplicate structure or pattern guidance
- Examples of correct choices (non-exhaustive): TypeScript/JavaScript → vitest (not jest), Python → pytest (not unittest), Go → testify (not stdlib only), Java → JUnit 5 + Mockito
- Stub files for unpopulated languages must explicitly name a `TODO: populate` placeholder per test type rather than leaving sections empty

## Acceptance Criteria

- [ ] Each populated language subdir contains `test-frameworks.md`
- [ ] No test type guidance duplicates `testing-standards.md` content
- [ ] Stub files contain explicit TODO placeholders, not empty sections

## Dependencies

- REQ-001 (library-standards-doc) — test-frameworks.md lives within each language subdir
