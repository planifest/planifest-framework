---
title: "Feature Brief - Setup Refresh Skill"
summary: "The business case, scope, and product requirements for the feature."
status: "draft"
version: "0.1.0"
---
# Feature Brief - Setup Refresh Skill

**Feature ID:** 0000020-setup-refresh-skill

> Folded in from backlog entry `0000013-setup-refresh-skill-preserving-settings` at P0 pickup (2026-07-31). Original problem statement and suggested action are preserved below; scope decisions were confirmed with the human during P0 coaching.

---

## Business Goal

Refreshing a Planifest install's generated artifacts (`CLAUDE.md`, `.claude/hooks/`, `.claude/skills/`, etc.) after the framework source changes currently requires manually reconstructing the original `setup.sh`/`setup.ps1` invocation — the correct tool name and every flag previously used — by reading installed hook wiring and marker files. None of this is recorded directly today. This exact reverse-engineering was done by hand during the 0000018 session that filed this backlog item. A refresh skill removes that manual step for both humans and agents doing framework maintenance.

---

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| setup-refresh-skill | As a developer or agent maintaining a Planifest install, I can invoke a skill that detects the currently installed tool and reconstructs the setup flags in effect from installed hook wiring and marker files, so that I don't have to manually reverse-engineer them | must-have | 1 |
| setup-refresh-skill | As a developer or agent, I can have the skill delete only the boot files `setup.sh`/`setup.ps1` won't overwrite on their own (`CLAUDE.md`, `AGENTS.md`) and re-invoke the correct setup script with the reconstructed flags, so that templates actually regenerate without touching `settings.local.json` or other user-owned files | must-have | 1 |
| setup-refresh-skill | As a framework maintainer, I can have `setup.sh`/`setup.ps1` persist the flags used at install time to a marker file, so that future refreshes read them directly instead of inferring them from hook wiring | should-have | 1 |

---

## Waves

Single wave — all three stories are one cohesive feature (detect → reconstruct → confirm → refresh, plus the persistence follow-on that makes future reconstructions exact).

| Wave | Features Included | Ships When |
|------|-------------------|------------|
| 1 | setup-refresh-skill (all 3 stories) | Skill installed, detects all setup.sh/setup.ps1-supported tools, reconstructs flags with confidence reporting, persists flags at install time |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| `planifest-refresh-setup` (skill) | component-pack | new | Detects installed tool, reconstructs active setup flags from hook wiring/marker files, reports confidence, safely deletes regenerable boot files, re-invokes setup.sh/setup.ps1 |
| `setup-hook-integration` | component-pack | existing | `setup.sh`/`setup.ps1` gain a small addition: write a flags-used marker file at install time |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| `.claude/.planifest-setup-flags` (marker file, exact name TBD in spec) | `setup-hook-integration` | read-only by `planifest-refresh-setup` |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| `planifest-refresh-setup` | `setup.sh` / `setup.ps1` | shell exec | invokes the correct script for the detected tool with the reconstructed/confirmed flag set |

---

## Stack

No new stack. Matches the existing `setup-hook-integration` component: Bash (`setup.sh`), PowerShell (`setup.ps1`), Node `.mjs` hooks, Markdown skill authoring. No new external dependencies.

| Concern | Decision |
|---------|----------|
| Language | Bash, PowerShell, Markdown (skill) |
| Runtime | Node (existing hooks only, no new runtime) |
| Framework | none |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | existing `tests/` shell/PowerShell test scripts |
| IaC | none |
| Cloud | none |
| Compute | local CLI |
| CI | GitHub Actions (existing) |
| Build target | local |

---

## Scope Boundaries

### In Scope
- A skill that detects the installed tool (`.claude/`, `.cursor/`, `.windsurf/`, `.clinerules`, `.agents/` + `OPENAI_*`, `.opencode/`) — full parity with what `setup.sh`/`setup.ps1` already support
- Reconstructing active flags from installed hook wiring and marker files (context-mode hooks → `--context-mode-mcp`; telemetry hooks + URL → `--structured-telemetry-mcp` + `--backend-url`; `plan/.orchestrator-strict` → `--strict-orchestrator`; `attribution.txt` under skills dir → `--include-full-skill-library`)
- Confidence reporting: when reconstruction is ambiguous or partial, list what was found plus confidence, and require human confirmation before running setup
- Deleting only `CLAUDE.md`/`AGENTS.md` (the boot files setup won't overwrite on their own) — never `settings.local.json` or other user-owned files
- Re-invoking the correct setup script for the detected tool with the confirmed flags
- `setup.sh`/`setup.ps1` writing a flags-used marker file at install time, read preferentially by the refresh skill on future runs

### Out of Scope
- General `setup.sh`/`setup.ps1` parity fixes unrelated to flag reconstruction/persistence (the known `.ps1` drift referenced in the backlog entry is a pre-existing, separately-tracked concern)
- New setup flags not already supported by `setup.sh`/`setup.ps1`

### Deferred
- None — both suggested actions from the backlog entry were pulled into this feature's scope per human confirmation during P0

---

## Non-Functional Requirements

This is a local CLI/dev-tooling skill — no latency/availability/throughput targets apply. The binding non-functional requirement is safety:

| NFR | Target | Measurement |
|-----|--------|-------------|
| Safety (no data loss) | Never delete/modify `settings.local.json` or any file outside the declared boot-file deletion list | Requirement traced to a test asserting user-owned files survive a refresh run |
| Correctness (no silent misconfiguration) | Never run setup with an inferred flag below full confidence without human confirmation | Requirement traced to a test asserting ambiguous detection halts for confirmation |

---

## Constraints and Assumptions

### Constraints
- No new external dependencies
- This feature's own additions to `setup.sh`/`setup.ps1` (the flags-used marker write) must stay in parity between the two scripts, even though the pre-existing general `.ps1` drift is out of scope

### Assumptions
- Installed hook wiring in `.claude/settings.json` (and each tool's equivalent) reliably signals which flags were used at install time — agents will flag if this conflicts during spec
- If the flags-used marker file from this feature already exists, it is preferred over inference from hook wiring

---

## Scenario Paths

See Scope Lock Challenge entries in `plan/current/build-log.md` (P0 phase block) for the confirmed answers.

**Happy path:** {{pending Scope Lock Challenge}}

**First-run path:** {{pending Scope Lock Challenge}}

**Error / sad path:** {{pending Scope Lock Challenge}}

**Cross-session continuity:** {{pending Scope Lock Challenge}}

---

## Acceptance Criteria

- [ ] Skill detects the installed tool across all tools `setup.sh`/`setup.ps1` support, and `setup.ps1`'s equivalents
- [ ] Skill reconstructs the active flag set from hook wiring and marker files, reporting confidence per flag
- [ ] Skill halts for human confirmation when any flag's reconstruction is ambiguous or partial, before running setup
- [ ] Skill deletes only `CLAUDE.md`/`AGENTS.md`, never `settings.local.json` or other user-owned files
- [ ] Skill re-invokes the correct setup script with the confirmed flags
- [ ] `setup.sh` and `setup.ps1` both write a flags-used marker file at install time, in parity with each other

---

*This brief will be read by the orchestrator skill. See [planifest/skills/orchestrator/SKILL.md](../skills/orchestrator/SKILL.md)*
