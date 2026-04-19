---
title: "Requirement: REQ-013 - Per-tool setup scripts for all 9 supported tools"
summary: "Each of the 9 supported tools has a dedicated idempotent setup script pair (sh + ps1)."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-013 - Per-tool setup scripts for all 9 supported tools

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief Track C scope; DD-005
**Priority:** must-have

---

## Functional Requirements

- A `setup/{tool}.sh` and `setup/{tool}.ps1` file exists for each of the 9 supported tools: `claude-code`, `cursor`, `windsurf`, `cline`, `codex-cli`, `opencode`, `copilot`, `antigravity`, `roo-code`.
- All setup scripts are idempotent (safe to re-run on an already-configured project).
- All setup scripts print a `[Planifest]` prefixed confirmation or warning on completion.
- The existing `setup.sh` / `setup.ps1` (root-level, claude-code specific) is updated to include enforcement hook installation (REQ-008) and is not replaced by the per-tool scripts.
- Per-tool scripts are invocable standalone; they do not source the root setup script.
- Windows PowerShell scripts (`*.ps1`) achieve functional parity with the shell scripts on supported platforms; Tier 1b (codex-cli) Windows limitation is documented, not implemented.

## Acceptance Criteria

- [ ] 9 × 2 = 18 setup script files exist (sh + ps1 per tool).
- [ ] Re-running any setup script on an already-configured project produces no duplicates and exits 0.
- [ ] Each script prints a completion message.
- [ ] `setup/codex-cli.ps1` prints the Windows-unsupported warning and exits 0 without modifying config.

## Dependencies

- REQ-009, REQ-010, REQ-011, REQ-012 (adapters and configs must exist for scripts to register).
