---
title: "Requirement: REQ-003 - skill-sync re-run in setup.ps1 main dispatch"
summary: "After each tool setup, setup.ps1 must call skill-sync.ps1 sync to re-sync external skills, matching setup.sh's run_tool_setup behaviour."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - skill-sync re-run in setup.ps1 main dispatch

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** US-003 — As a framework maintainer, setup.ps1 and setup.sh produce equivalent results for all shared flags and behaviours
**Priority:** must-have

---

## Functional Requirements
- After `Invoke-PlanifestSetup` completes for a given tool, setup.ps1 must invoke `skill-sync.ps1 sync <tool>` to re-sync external skills
- The sync call must be guarded: if `planifest-framework/scripts/skill-sync.ps1` does not exist, skip silently without error
- The sync call must suppress non-fatal errors (mirror setup.sh's `2>/dev/null || true` pattern — use `try/catch` or `-ErrorAction SilentlyContinue`)
- The guard and sync call must apply in both the single-tool path (`elseif ($ValidTools -contains $ToolLower)`) and the `all` path (`foreach ($t in $ValidTools)`)
- Reference implementation: setup.sh `run_tool_setup()` lines after the `setup_tool` call

## Acceptance Criteria
- [ ] setup.ps1 main dispatch calls `skill-sync.ps1 sync $toolName` after each `Invoke-PlanifestSetup` call
- [ ] If `planifest-framework/scripts/skill-sync.ps1` does not exist, setup.ps1 completes without error
- [ ] The sync call is present in both the single-tool and `all` dispatch branches
- [ ] `setup.ps1 all` invokes skill-sync for every tool in `$ValidTools`

## Dependencies
- `planifest-framework/scripts/skill-sync.ps1` must exist (confirmed)
- REQ-002 (roo-code in ValidTools) must be complete before the `all` path is meaningful
