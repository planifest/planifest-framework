---
title: "Requirement: REQ-003 - skill-dir-normalisation"
summary: "Audit all external-skills directories for name-vs-directory mismatch and rename mismatched directories to match the kebab-case of the SKILL.md name field."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - skill-dir-normalisation

**Skill:** planifest-implementer
**Feature:** 0000010-framework-quality-improvements
**Source:** Human-identified gap: skill directories may not match the name field in SKILL.md frontmatter, making skills undiscoverable by name.
**Priority:** must-have

> Written by the spec-agent. This file contains the requirements for a single feature so that agents can build it without loading the entire project scope.

---

## Functional Requirements

- For every directory under `planifest-framework/external-skills/`, read the SKILL.md frontmatter `name` field
- Convert the `name` field value to kebab-case (lowercase, spaces → hyphens, strip non-alphanumeric except hyphens)
- If the directory name does not equal the kebab-case name: rename the directory to the kebab-case name
- After all renames, update `planifest-framework/external-skills/README.md` to reflect any changed directory names in the skill index table
- If two skills would normalise to the same kebab-case name (collision): keep the first encountered, flag the collision in a `plan/current/req-003-collisions.md` report, and do not rename the duplicate

## Acceptance Criteria

- [ ] A dry-run audit report is produced first (written to `plan/current/req-003-audit.md`) listing: total skills audited, count matching, count mismatched, each mismatch as `dir-name → normalised-name`
- [ ] Human (or continuous run) reviews the audit before renames are applied
- [ ] All mismatched directories are renamed to their normalised kebab-case name
- [ ] All file contents inside renamed directories are unchanged
- [ ] `planifest-framework/external-skills/README.md` skill index reflects the post-rename directory names
- [ ] No skill directory that was already correctly named is modified
- [ ] Any collision is documented in `plan/current/req-003-collisions.md` and the duplicate is left unrenamed

## Dependencies

- Should run after REQ-004 (additional skills added) so the normalisation covers new skills too — if REQ-004 is parallelised, REQ-003 renames run as a final pass after REQ-004 writes are complete
