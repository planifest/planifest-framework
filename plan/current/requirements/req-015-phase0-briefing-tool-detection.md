---
title: "Requirement: REQ-015 - Phase 0 opens with structured briefing, detects tool, and verifies hooks"
summary: "On first invocation, Phase 0 presents the phase table, detects the active tool, and validates hook installation."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-015 - Phase 0 structured briefing and hooks health check

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-14; DD-007, DD-010
**Priority:** must-have

---

## Functional Requirements

- On first invocation of the orchestrator (no existing `plan/current/` artefacts), Phase 0 opens with:
  1. A phase table listing all 8 phases (P0–P7) with status indicators.
  2. A standing invitation to redirect: `"Tell me if you want to skip a phase or redirect at any time."`
  3. Tool detection: check `PLANIFEST_TOOL` env var → directory markers (`.claude/`, `.cursor/`, `.windsurf/`, `.clinerules/`, `.codex/`, `opencode.json`) → prompt human.
  4. Hooks health check: verify hook registration files exist for the detected tool. If missing, print an inline remediation command (copy-pasteable).
  5. For Tier 3 tools: inform human that deterministic enforcement is unavailable.
- If hooks are healthy: `P0: Hooks verified for {tool}. ✓`
- If hooks are missing: `P0: ⚠ Hooks not installed for {tool}. Run: {copy-pasteable command}`
- The hooks health check checks for the presence of the hook registration file, not just the adapter scripts.

## Acceptance Criteria

- [ ] Phase 0 first response includes the phase table.
- [ ] Phase 0 detects `PLANIFEST_TOOL` env var when set.
- [ ] Phase 0 falls back to directory marker detection when env var is absent.
- [ ] Phase 0 prompts human when no directory markers found.
- [ ] Hooks healthy: confirmation printed with `✓`.
- [ ] Hooks missing: remediation command printed verbatim (copy-pasteable).
- [ ] Tier 3 tool detected: human warned that enforcement is instruction-based only.

## Dependencies

- DD-007 (tool detection priority order is locked).
- DD-010 (remediation command must be inline and copy-pasteable).
- REQ-013 (per-tool setup scripts must exist for remediation commands to reference).
