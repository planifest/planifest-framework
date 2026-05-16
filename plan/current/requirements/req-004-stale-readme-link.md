---
title: "Requirement: REQ-004 - Remove stale req-005 link from external-skills README"
summary: "Remove the broken link to plan/current/requirements/req-005-open-source-skill-library.md from external-skills/README.md."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-004 - Remove stale req-005 link from external-skills README

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** P0 framework audit — line 25 of external-skills/README.md links to a requirement file that was archived with feature 0000009 and no longer exists at the referenced path
**Priority:** should-have

---

## Functional Requirements
- Line 25 of `planifest-framework/external-skills/README.md` must not link to `plan/current/requirements/req-005-open-source-skill-library.md`
- The sentence or paragraph containing the link must either be removed entirely or rewritten without the broken reference
- No other content in the README should be altered

## Acceptance Criteria
- [ ] `external-skills/README.md` contains no reference to `req-005-open-source-skill-library.md`
- [ ] `external-skills/README.md` contains no reference to `plan/current/requirements/` (that path is pipeline-local and always stale after archiving)
- [ ] The README remains coherent and accurate after the edit

## Dependencies
- None
