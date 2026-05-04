---
title: "Requirement: req-009 - em-dash-prohibition"
status: "active"
version: "0.1.0"
---
# Requirement: req-009 - Em dash prohibition

**Feature:** 0000007-agent-optimisation (fast-path amendment 2026-05-04)
**Source:** Post-ship human review
**Priority:** must-have

---

## Functional Requirements

### Add Category 7 to language-quirks-en-gb.md

Add a Category 7 (Prohibited punctuation) section to `planifest-framework/standards/language-quirks-en-gb.md`.

The category MUST state:

- Em dashes (`—`) are prohibited in all framework prose, headings, and documentation
- The only exception is when the syntax of the output format strictly requires one
- Any meaning carried by an em dash can be expressed with a colon, comma, or full stop
- Em dashes are strongly associated with AI-generated text and must be avoided on that basis
- In code (Category 1), em dashes are not corrected if they appear as literal string content

The section MUST include a before/after example demonstrating correct usage.

### Apply the rule to the file itself

The file's own heading (`# Language Quirks — en-GB`) uses an em dash and MUST be corrected to use a colon (`# Language Quirks: en-GB`) as the first application of the new rule.

## Acceptance Criteria

- [ ] `language-quirks-en-gb.md` contains a Category 7 section prohibiting em dashes
- [ ] The file's own heading uses a colon, not an em dash
- [ ] Category 7 includes at least one before/after example

## Dependencies

- req-008 (language-quirks-en-gb.md must exist before Category 7 can be added)
