---
title: "Requirement: REQ-006 - test-0000009 assertion for setup.ps1 include-full-skill-library"
summary: "Add assertions to test-0000009-rail-tightening.sh confirming setup.ps1 implements --include-full-skill-library."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-006 - test-0000009 assertion for setup.ps1 include-full-skill-library

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** US-004 — As a framework contributor, tests catch regressions in setup.ps1 parity; existing lines 90–91 check setup.sh but not setup.ps1
**Priority:** must-have

---

## Functional Requirements
- `planifest-framework/tests/test-0000009-rail-tightening.sh` must gain two new assertions in the REQ-004 block (open-source skill library section):
  1. `setup.ps1` contains the string `include-full-skill-library` — mirrors the existing setup.sh assertion at lines 90–91
  2. `setup.ps1` contains the string `Copy-ExternalSkills` — verifies the function exists, not just the flag string
- Assertions must use the existing `assert_equals` / `grep_has` helper pattern already in use in the file
- Assertions must be placed immediately after the existing setup.sh assertions (lines 90–91) within the same REQ-004 block

## Acceptance Criteria
- [ ] `test-0000009-rail-tightening.sh` contains `grep_has "include-full-skill-library" "$SETUP_PS1"` (or equivalent)
- [ ] `test-0000009-rail-tightening.sh` contains `grep_has "Copy-ExternalSkills" "$SETUP_PS1"` (or equivalent)
- [ ] Both new assertions use `assert_equals "yes"` consistent with the existing pattern
- [ ] Running the test suite passes after REQ-001 is implemented

## Dependencies
- REQ-001 must be complete (assertions will fail until the implementation exists)
- `SETUP_PS1` variable is already defined at line 12 of the test file — no new variable needed
