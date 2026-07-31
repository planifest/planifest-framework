---
title: "Requirement: REQ-002 - Flag reconstruction with confidence reporting"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-002 - Flag reconstruction with confidence reporting

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-001
**Priority:** must-have

---

## User Story

As a human on the loop, I can have the skill reconstruct the setup flags currently in effect from installed hook wiring and marker files, with a confidence level shown per flag, so that I don't have to manually reverse-engineer them.

---

## Functional Requirements
- If `.claude/.planifest-setup-flags` exists for the target tool, its recorded flags are read and reported at high confidence, taking precedence over inference
- If the marker file is absent or incomplete, each flag is inferred from installed hook wiring: context-mode hooks present under `.claude/hooks/context-mode/` → `--context-mode-mcp`; telemetry hooks present + a `PLANIFEST_TELEMETRY_URL` value wired into hook commands → `--structured-telemetry-mcp` plus `--backend-url <url>`; `plan/.orchestrator-strict` present → `--strict-orchestrator`; `attribution.txt` files present under the installed skills directory → `--include-full-skill-library`
- Each inferred flag is reported with a confidence level (e.g. high / medium / low) reflecting how directly the signal maps to the flag
- The full flag-by-flag report (source: marker file vs inferred, confidence level) is shown to the human on the loop before any file is touched

## Acceptance Criteria
- [ ] Marker file present and complete for the target tool: all flags reported at high confidence, sourced from the marker
- [ ] Marker file absent: all flags inferred from hook wiring, each with an explicit confidence level
- [ ] Each of the four known flag signals (context-mode, telemetry, strict-orchestrator, include-full-skill-library) is correctly mapped when its corresponding installed-state signal is present
- [ ] The report is shown to the human on the loop before REQ-003's confirmation gate, never after

## Dependencies
- REQ-001 (tool must be identified before its install state can be read)
