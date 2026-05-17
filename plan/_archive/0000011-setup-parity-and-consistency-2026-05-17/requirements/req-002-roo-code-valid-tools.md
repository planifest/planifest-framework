---
title: "Requirement: REQ-002 - roo-code in setup.ps1 ValidTools"
summary: "Add roo-code to setup.ps1 ValidTools so the tool can be set up on Windows."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-002 - roo-code in setup.ps1 ValidTools

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** US-002 — As a Windows user running `setup.ps1 roo-code`, setup succeeds instead of "Unknown tool"
**Priority:** must-have

---

## Functional Requirements
- `'roo-code'` must be added to the `$ValidTools` array in setup.ps1
- The position must match setup.sh's `VALID_TOOLS` ordering (after `cline`, before `opencode`)
- `setup/roo-code.ps1` already exists and is correct — no changes required to that file

## Acceptance Criteria
- [ ] `$ValidTools` in setup.ps1 contains `'roo-code'`
- [ ] `setup.ps1 roo-code` exits with code 0 and does not print "Unknown tool"
- [ ] `setup.ps1` help output (no args) lists `roo-code` in the Tools section

## Dependencies
- `planifest-framework/setup/roo-code.ps1` must exist (confirmed)
