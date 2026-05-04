---
title: "Requirement: REQ-012 - Tier 3: MCP + instructions fallback for unsupported tools"
summary: "Copilot, Antigravity, and Roo Code receive instructions-only enforcement with a clear human warning."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-012 - Tier 3: MCP + instructions fallback

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief AC-12; DD-005
**Priority:** must-have

---

## Functional Requirements

- Setup scripts for Tier 3 tools (`setup/copilot.sh`, `setup/antigravity.sh`, `setup/roo-code.sh`) complete without error and produce no hook registrations.
- Each Tier 3 setup script prints a clear warning: `[Planifest] {tool} does not support deterministic enforcement hooks. Enforcement is instruction-based only.`
- The Phase 0 orchestrator UX (DD-007 Step 3) detects Tier 3 tools and informs the human inline during the tool detection step.
- No adapter scripts are created for Tier 3 tools (there is no hook system to adapt to).
- Tier 3 tools rely on the `UserPromptSubmit` context injection for scope awareness (if their native instruction system supports it) or on SKILL.md instruction compliance only.

## Acceptance Criteria

- [ ] Setup scripts for copilot, antigravity, roo-code complete without error.
- [ ] Each Tier 3 setup script prints the deterministic enforcement unavailable warning.
- [ ] No hook registration files are created for Tier 3 tools.
- [ ] Phase 0 orchestrator flow identifies Tier 3 tools and warns the human (tested via SKILL.md walkthrough).

## Dependencies

- REQ-014 (orchestrator Phase 0 tool detection must identify Tier 3 tools).
