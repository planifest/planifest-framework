---
title: "Requirement: REQ-004 - about.md Template and Read/Write Protocol"
summary: "New about.template.md; docs/about.md read at P0 and written at P7."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-004 - about.md Template and Read/Write Protocol

**Skill:** planifest-orchestrator, planifest-ship-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-002
**Priority:** must-have

---

## User Story

As a framework user, I receive a suggested version number after confirming adoption mode, so that I don't have to derive it manually.

---

## Functional Requirements
- A new template is created at `planifest-framework/templates/about.template.md` with YAML frontmatter containing at minimum: `version`, `feature`, `updated`
- At P0, the orchestrator reads `docs/about.md` (if present) to extract the current version for use in REQ-003
- At P7, the ship-agent writes the confirmed version to `docs/about.md` using the template format
- The ship-agent creates the `docs/` directory if it does not exist before writing
- The write at P7 is a blocking step — pipeline does not proceed past P7 if the write fails
- `docs/about.md` is committed as part of the P7 commit

## Acceptance Criteria
- [ ] `planifest-framework/templates/about.template.md` exists with `version`, `feature`, and `updated` YAML frontmatter fields
- [ ] Orchestrator reads `docs/about.md` at P0 and extracts the version field
- [ ] Ship-agent creates `docs/` if absent before writing
- [ ] Ship-agent writes `docs/about.md` with confirmed version at P7
- [ ] Write failure at P7 halts the pipeline with a clear error message
- [ ] `docs/about.md` is included in the P7 commit

## Input Validation
- [ ] Input source: filesystem read of `docs/about.md` YAML frontmatter `version` field
- [ ] Allowed character pattern: `[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?` — semver format; non-matching values treated as malformed
- [ ] Maximum length: 32 characters — content beyond this limit treated as malformed
- [ ] Failure behaviour: on malformed or missing version, fall back to REQ-009 signal-based detection and prompt human to confirm
- [ ] Logging policy: raw value logged in P0 audit trail as "version read from docs/about.md: {value}"

## Dependencies
- REQ-009 (malformed version fallback)
- REQ-013 (ship-agent docs/ creation)
