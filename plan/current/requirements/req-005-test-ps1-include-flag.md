---
title: "Requirement: REQ-005 - test_setup.ps1 coverage for --include-full-skill-library"
summary: "Add a test block to test_setup.ps1 that exercises the --include-full-skill-library flag end-to-end."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-005 - test_setup.ps1 coverage for --include-full-skill-library

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** US-004 — As a framework contributor, tests catch regressions in setup.ps1 parity
**Priority:** must-have

---

## Functional Requirements
- `planifest-framework/tests/test_setup.ps1` must include a test block that:
  - Runs `setup.ps1 claude-code --include-full-skill-library` in the existing temp workspace
  - Asserts that at least one external skill directory exists under `.claude/skills/` (i.e. a dir not present in the built-in skills set)
  - Asserts that the installed external skill directory contains a `SKILL.md` file
  - Asserts that the installed external skill directory contains an `attribution.txt` file
  - Asserts that `.claude/skills/.planifest-manifest` includes at least one path containing an external skill name
- The test block must follow the existing pattern in test_setup.ps1 (throw on failure, `Write-Host` on success)
- The test must be deterministic: it must not depend on a specific skill name, only on the presence of at least one valid external skill

## Acceptance Criteria
- [ ] `test_setup.ps1` contains a test section headed with `--- Testing: --include-full-skill-library ---` (or equivalent label)
- [ ] Test asserts at least one subdirectory under `.claude\skills\` contains both `SKILL.md` and `attribution.txt` after the flag run
- [ ] Test asserts `.planifest-manifest` includes an external skill path
- [ ] Re-running `setup.ps1 claude-code` (without the flag) after the flag run and then checking `.claude\skills\` does not leave orphaned external skill dirs — test asserts external skill dirs are absent after a plain re-run

## Dependencies
- REQ-001 must be complete (test exercises the implementation)
