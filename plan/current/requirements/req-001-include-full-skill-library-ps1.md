---
title: "Requirement: REQ-001 - include-full-skill-library flag in setup.ps1"
summary: "Implement the --include-full-skill-library flag in setup.ps1 with full parity to setup.sh."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-001 - include-full-skill-library flag in setup.ps1

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** US-001 — As a Windows user running setup.ps1 with `--include-full-skill-library`, external skills are copied to my tool's skill directory with the same behaviour as setup.sh
**Priority:** must-have

---

## Functional Requirements
- setup.ps1 must recognise `--include-full-skill-library` as a valid flag in the `while`/`switch` arg parser
- `$IncludeFullSkillLibrary` must be initialised to `$false` in the variable block alongside the other boolean flags
- A `Copy-ExternalSkills` function must be implemented that:
  - Accepts a single parameter `$TargetDir` (the tool's skill directory path)
  - Iterates over all subdirectories in `planifest-framework/external-skills/`
  - Skips any directory missing `SKILL.md`, printing a per-skip warning message
  - Skips any directory missing `attribution.txt`, printing a per-skip warning message
  - Copies `SKILL.md` and `attribution.txt` (and only those two files) to `$TargetDir/<skill-name>/`
  - Prints `  + [external] <skill-name>/SKILL.md` for each successful install
  - Prints a final count: `  [external-skills] N skill(s) installed` or `  [external-skills] no valid skills found (each needs SKILL.md + attribution.txt)` when count is zero
- `Copy-ExternalSkills` must be called in `Invoke-PlanifestSetup` immediately after `Copy-PlanifestSkills`, gated on `$IncludeFullSkillLibrary -eq $true`
- Installed external skill directories must be recorded in `.planifest-manifest` so that re-run cleanup removes them
- The help text block (shown when no tool arg is given) must include `--include-full-skill-library` with a description matching setup.sh wording

## Acceptance Criteria
- [ ] `$IncludeFullSkillLibrary = $false` present in the variable init block alongside `$ContextModeMcp`, `$StructuredTelemetryMcp`, `$StrictOrchestrator`
- [ ] `'--include-full-skill-library' { $IncludeFullSkillLibrary = $true; $i++ }` present in the `switch` block
- [ ] `Copy-ExternalSkills` function exists in setup.ps1
- [ ] Running `setup.ps1 claude-code --include-full-skill-library` copies at least one external skill (SKILL.md + attribution.txt) into `.claude/skills/`
- [ ] Running `setup.ps1 claude-code --include-full-skill-library` followed by `setup.ps1 claude-code --include-full-skill-library` (re-run) produces a clean result — no duplicate or orphaned dirs
- [ ] Running `setup.ps1 claude-code` (without the flag) does NOT copy any external skills
- [ ] Help output (no args) includes `--include-full-skill-library`

## Dependencies
- `planifest-framework/external-skills/` must be populated (confirmed: all dirs have SKILL.md + attribution.txt)
- `.planifest-manifest` write logic already exists in `Invoke-PlanifestSetup` — external skill dirs must be included in the same manifest write
