---
title: "Requirement: REQ-013 - formatting-standards"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-013 - formatting-standards

**Feature:** 0000005-framework-governance
**Source:** locale standard, date format standard, response verbosity standard user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

**Date format:**
- All human-readable dates in document body text must use DD MMM YYYY (e.g. 02 May 2026)
- Filename prefixes where sort order must match chronological order must use YYYY-MM-DD (e.g. `2026-05-02-changelog.md`)
- Machine-readable fields (frontmatter `date:`, JSON values) must use YYYY-MM-DD
- Formats MM/DD/YYYY, DD/MM/YYYY, YYYY/MM/DD, and ISO 8601 in body text are forbidden

**Locale:**
- All prose, labels, comments, and documentation must use British English spellings (e.g. "colour", "organise", "licence" as noun, "behaviour")
- Code identifiers follow the conventions of the language/framework in use — American English in identifiers is acceptable where it is the ecosystem norm (e.g. `color` in CSS, `initialize` in Ruby, `color` in React prop names)
- `formatting-standards.md` must clearly state: Planifest currently supports English only; defaults to British English; multilingual support is planned for a future release

**Response verbosity:**
- Agents must default to the shortest response that fully communicates the outcome
- Partial sentences and single-line confirmations are correct when no explanation is needed
- Agents must not: summarise what they just did, narrate reasoning steps, or pad with affirmatory language ("Certainly!", "Great question!", "As requested,")
- Explanation is appropriate when: a decision is non-obvious, a constraint is being applied, or the human has asked why
- `formatting-standards.md` must include concrete examples contrasting verbose and brief responses

**`formatting-standards.md` must be added to `bundle_standards` in all SKILL.md files**

## Acceptance Criteria

- [ ] `planifest-framework/standards/formatting-standards.md` exists with all three sections (date, locale, verbosity)
- [ ] Locale section states English-only support, British English default, and multilingual deferral
- [ ] Verbosity section includes concrete before/after examples
- [ ] `formatting-standards.md` added to `bundle_standards` in orchestrator, codegen-agent, validate-agent, spec-agent, adr-agent, docs-agent, ship-agent, security-agent, migrator SKILL.md files

## Dependencies

- REQ-014 (migration-infrastructure) — migrations enforce the date and locale standards on existing artifacts
