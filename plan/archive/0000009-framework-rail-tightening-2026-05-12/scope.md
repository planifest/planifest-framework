---
title: "Scope - 0000009-framework-rail-tightening"
version: "0.1.0"
phase: 1
---
# Scope — 0000009-framework-rail-tightening (Phase 1)

## In Scope

- REQ-001: Fix all bare `.skips` references in `planifest-framework/skills/planifest-orchestrator/SKILL.md` to `plan/current/.skips`
- REQ-002: Auto-trigger hook script + CLAUDE.md fallback for orchestrator session-start; installed by setup.sh and setup.ps1 for Claude Code
- REQ-003: Subagent Decomposition Protocol section added to orchestrator SKILL.md
- REQ-004: Skill-to-requirement mapping in design.md (`## Skill Map`); orchestrator SKILL.md updated with map protocol at P0 and gate checkpoints
- REQ-005: `planifest-framework/external-skills/` directory; `--include-full-skill-library` flag in setup.sh and setup.ps1; minimum 3 curated permissive-licence skills with attribution.txt; external-skills/README.md
- REQ-006: `plan/current/pause.md` written on command; orchestrator SKILL.md resume detection extended to read pause.md; pause.md deleted on confirmed resume
- REQ-007: gate-write.mjs Windows path fix in source (`planifest-framework/hooks/enforcement/`) and deployed (`.claude/hooks/enforcement/`); `pause.md` added to ALWAYS_PERMITTED_FILES; regression tests

## Out of Scope

- Changes to any phase agent skill files (spec-agent, codegen-agent, etc.) beyond what the orchestrator passes via context
- New MCP plugins or server-side infrastructure
- Tier 1 adapter support in setup.ps1 (Phase 2)
- bash Append-OverrideInstructions and Copy-CapabilitySkills parity (Phase 2)
- Override instructions injection into skill/workflow files (Phase 2)
- TypeScript adapter for OpenCode/KiloCode (Phase 3)
- Gemini CLI, VS Code Copilot, JetBrains Copilot enforcement
- Windsurf hook registration (conditional on Phase 2 investigation)

## Deferred

- Phase 2 requirements (REQ-008 through REQ-012) — blocked on Phase 1 shipping
- Phase 3 requirement (REQ-013 TypeScript adapter) — blocked on Phase 2 shipping
- Per-tool routing rules fallback for non-plugin tools (tracked in 0000008 ADR-002)
- OpenCode/KiloCode full session continuity — owned by context-mode, not Planifest
