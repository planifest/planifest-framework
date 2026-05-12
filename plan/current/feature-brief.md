---
title: "Feature Brief - framework-rail-tightening"
summary: "Orchestrator improvements, open-source skill library, setup script parity, and platform adapter completeness."
status: "draft"
version: "0.1.0"
---
# Feature Brief - framework-rail-tightening

**Feature ID:** 0000009-framework-rail-tightening

---

## Business Goal

The framework has accumulated gaps across three areas: (1) the orchestrator spec and its implementation diverge in small but meaningful ways that cause incorrect behaviour; (2) the bash and PS1 setup scripts have drifted apart — features shipped in bash were never ported to PS1; (3) platform coverage is incomplete — Cursor, Windsurf, Cline, roo-code, opencode, and KiloCode users on Windows have no Planifest enforcement. Additionally, a Windows path-separator bug in the gate-write hook blocks writes to `plan/archive/` and `plan/` paths once `plan/current/` is cleared, breaking P7 for all Windows users. This feature closes all three gap categories and fixes the bug.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| Fix .skips path ambiguity | As a framework user, consistent `plan/current/.skips` reference in orchestrator means skip tracking works on all tools | must-have | 1 |
| Auto-trigger orchestrator | As a user opening a planifest project, the orchestrator starts automatically so I never invoke it manually | must-have | 1 |
| Subagent decomposition | As a framework user, phase agents decompose hard tasks into subagents using best-fit skills so complex work is handled correctly | must-have | 1 |
| Skill-to-requirement mapping | As a framework user, I see which skill handles each requirement from P0 onwards, re-evaluated at each gate | must-have | 1 |
| Open-source skill library | As a framework user, I can opt into curated open-source skills at setup time with `--include-full-skill-library` | should-have | 1 |
| Pause and resume | As a framework user, I can pause a session with a command and resume from exactly that point | must-have | 1 |
| Override instructions in skills and workflows | As a user running setup, my `planifest-overrides/instructions/` files are injected into the orchestrator SKILL.md and workflow files | must-have | 2 |
| Bash: Append-OverrideInstructions parity | As a bash setup user, override instructions are appended to the boot file identically to PS1 | must-have | 2 |
| Bash: Copy-CapabilitySkills parity | As a bash setup user, capability skills are copied from `planifest-overrides/capability-skills/` into the tool's skill dir | must-have | 2 |
| PS1: Tier 1 adapter support | As a Cursor/Windsurf/Cline/roo-code user on Windows, gate-write and check-design are wired into my tool's hook system | must-have | 2 |
| PS1: opencode tool support | As an opencode user on Windows, `setup.ps1 opencode` works | must-have | 2 |
| TypeScript adapter for OpenCode/KiloCode | As an opencode or kilocode user, Planifest gate-write and check-design are enforced via `tool.execute.before`/`tool.execute.after` | must-have | 3 |
| Fix gate-write Windows path bug | As a Windows user, P7 archive writes succeed and plan/ paths are always-permitted regardless of design.md state | must-have | 1 |

---

## Phases

| Phase | Features Included | Ships When |
|-------|-------------------|------------|
| 1 | .skips fix, auto-trigger, subagent decomposition, skill mapping, skill library, pause/resume, gate-write Windows fix | All P1 requirements pass validation and tests |
| 2 | Override instructions in skills/workflows, bash parity (REQ-7, REQ-8), PS1 Tier 1 + opencode | All P2 requirements pass validation and tests |
| 3 | TypeScript adapter for OpenCode/KiloCode | Adapter passes enforcement tests on opencode and kilocode |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Skills, setup scripts, hooks, templates, standards |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| plan/current/ | planifest-framework | all phase agents (read) |
| planifest-overrides/instructions/ | project (human-owned) | planifest-framework (read-only at setup time) |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| setup.ps1 | Cursor/Windsurf/Cline/roo-code hook config | settings.json write | Idempotent hook entry merge |
| setup.ps1/setup.sh | orchestrator SKILL.md + workflow files | file append | Sentinel-marker block, strip-and-replace on re-run |
| OpenCode/KiloCode TypeScript plugin | gate-write.mjs / check-design.mjs | `tool.execute.before` spawn | Exit code 2 = block |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown, Bash, PowerShell, TypeScript |
| Runtime | Node.js (existing hooks), Bun (OpenCode/KiloCode adapter) |
| Framework | none |
| Frontend | none |
| Database | none |
| Testing | existing bash test suite (`planifest-framework/tests/`) |
| Build target | local |

---

## Scope Boundaries

### In Scope
- REQ-1 through REQ-12 as specified in discovery
- Test coverage for all new and modified setup script functions
- Source file fix for gate-write.mjs Windows path bug (`planifest-framework/hooks/enforcement/gate-write.mjs`)
- Updating orchestrator SKILL.md and workflow files for override instructions injection

### Out of Scope
- Changes to any phase agent skills beyond orchestrator wiring for REQ-2, REQ-3a, REQ-3b
- New MCP plugins or server-side infrastructure
- Windsurf hook registration if Windsurf does not expose a configurable hook settings file (documented as a conditional)
- Gemini CLI, VS Code Copilot, JetBrains Copilot enforcement support

### Deferred
- OpenCode/KiloCode full session continuity (capture/restore) — context-mode handles this; Planifest enforces gate-write/check-design only
- Per-tool routing rules fallback (tracked in 0000008 ADR-002 as deferred)

---

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Setup idempotency | Re-running setup produces no duplicate entries or sentinel blocks | Re-run test in test suite |
| Hook reliability | gate-write blocks a write when design.md absent on all supported tools | Per-tool acceptance test |
| Windows path correctness | gate-write always-permitted check passes for `plan/` and `plan/archive/` paths on Windows | Regression test added to test suite |

---

## Constraints and Assumptions

### Constraints
- `planifest-overrides/` must never be written to or deleted by setup scripts
- Commit messages must follow commit-standards.md (no AI attribution, ≤72-char subject)
- TypeScript adapter must use only Bun built-ins — no external npm dependencies
- Local git only — no fetch, pull, push; no worktrees; human raises PRs

### Assumptions
- Windsurf exposes a configurable hook settings file; if not, REQ-9 covers Cursor, Cline, and roo-code only and this is documented
- opencode and KiloCode plugin APIs are stable at current versions
- Existing bash Tier 1 adapter scripts (cursor.mjs, windsurf.mjs, cline.mjs) in `planifest-framework/hooks/adapters/` are reusable as-is for PS1 wiring

---

## Acceptance Criteria

- [ ] `plan/current/.skips` is the canonical path in orchestrator SKILL.md — no bare `.skips` references (REQ-1)
- [ ] Orchestrator auto-triggers on `UserPromptSubmit` hook in Claude Code; CLAUDE.md instruction present as fallback (REQ-2)
- [ ] Orchestrator SKILL.md instructs phase agents to decompose tasks into subagents with skill-library lookup and model-tier selection (REQ-3a)
- [ ] Orchestrator produces skill-to-requirement map at P0; re-evaluates at each phase gate; human confirms before each phase (REQ-3b)
- [ ] `--include-full-skill-library` flag copies curated open-source skills to tool skill dir; each skill directory contains `attribution.txt` with licence type, copyright holder, source URL, required attribution text, and full licence text at the bottom (REQ-4)
- [ ] On command, orchestrator writes `plan/current/pause.md` with phase, active task, last artifact, in-progress state; resume reads and restores (REQ-5)
- [ ] `setup.ps1` and `setup.sh` inject `planifest-overrides/instructions/` into orchestrator SKILL.md and workflow files with sentinel markers; idempotent on re-run (REQ-6)
- [ ] `setup.sh` appends `planifest-overrides/instructions/` to boot file with sentinel markers; strip-and-replace on re-run (REQ-7)
- [ ] `setup.sh` copies `planifest-overrides/capability-skills/` into tool's skill dir after `copy_skills` (REQ-8)
- [ ] `setup.ps1` installs Tier 1 adapters and wires gate-write into Cursor, Windsurf (if supported), Cline, and roo-code hook settings (REQ-9)
- [ ] `setup.ps1 opencode` runs without error; opencode in `$ValidTools` with corresponding `setup/opencode.ps1` (REQ-10)
- [ ] TypeScript adapter enforces gate-write/check-design via `tool.execute.before` on opencode and kilocode; blocks write when design.md absent (REQ-11)
- [ ] `planifest-framework/hooks/enforcement/gate-write.mjs` uses normalised path comparison; `plan/` and `plan/archive/` writes pass on Windows without design.md (REQ-12)
- [ ] `planifest-framework/hooks/enforcement/check-orchestrator-presence.mjs` injects a presence-check banner on every `UserPromptSubmit` when `plan/.orchestrator-active` exists; exits 0 silently when absent; registered in setup.sh and setup.ps1 (REQ-008)

---

*This brief will be read by the orchestrator skill. See [planifest/skills/orchestrator/SKILL.md](../skills/orchestrator/SKILL.md)*
