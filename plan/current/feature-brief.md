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
| `.claude/.planifest-setup-flags` — doubles as install-time flag record AND the refresh skill's retry cache (holds reconstructed/confirmed flags + last attempted command) | `setup-hook-integration` | read/write by `planifest-refresh-setup` |

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

**Happy path:** The human on the loop tells Claude which tool's setup to refresh (or Claude asks which tool, if the repo has more than one tool installed), and asks to re-run setup with current settings. The skill confirms that tool's install exists in the repo and works out which setup flags are currently active by reading the installed hook wiring and marker files, including a flags-used marker file if one is already present from a prior install. It then shows the human on the loop what it found, flag by flag, each with a confidence level. The human on the loop reviews and confirms. Only then does the skill delete `CLAUDE.md` and `AGENTS.md` (never `settings.local.json` or any other user-owned file) and re-run the correct setup script with the confirmed flags. Success looks like: the templates and boot files are freshly regenerated to match the current framework source, every flag that was in effect before is still in effect afterward, no user-owned file was touched, and the human on the loop never had to remember or manually reconstruct the original setup invocation themselves.

**First-run path:** The very first time the human on the loop runs the refresh skill on a given repo, no flags-used marker file exists yet, since that marker is new with this feature and only gets written going forward by setup.sh/setup.ps1. On this first run, the skill falls back to reading installed hook wiring alone (the same fallback it always uses whenever no marker file is present, whether that's because none was ever written or because it was deleted), and reports each flag's confidence on that basis. The human on the loop still sees the same flag-by-flag findings and confidence levels as any other run, and still must confirm before the skill deletes anything or re-runs setup. Nothing about the deletion or re-invocation behavior differs on a first run, only the source of the confidence reporting does.

Separately, if the skill is invoked on a repo with no Planifest install at all, there is no hook wiring and no marker file to read, so there is nothing to reconstruct. That is not this skill's job, it belongs to the initial setup.sh or setup.ps1 invocation, and the refresh skill should say so and stop rather than attempting a refresh.

**Error / sad path:** The most likely failure is the setup script itself failing partway through the re-invocation, for example a hook file it tries to write is blocked by a permissions error or a locked file. Because `CLAUDE.md` and `AGENTS.md` are only deleted after the human on the loop has already confirmed the flags, this failure happens after the point of no return for those two files. When it occurs, the skill stops immediately rather than retrying on its own, looks into what it can about the cause (whether the target path is locked, permission-denied, or held by another process), and tells the human on the loop plainly what setup reported, which step it reached, and that `CLAUDE.md` and/or `AGENTS.md` may now be missing pending a successful rerun. It prints the exact command it attempted as a code block so the human on the loop can copy it and retry manually, and it caches the reconstructed flags and command locally so the refresh can be re-run without repeating detection once the underlying issue is resolved. It confirms that `settings.local.json` and every other user-owned file were never touched, since those were never part of the deletion list to begin with.

**Cross-session continuity:** Before the human on the loop has confirmed the reconstructed flags, nothing is at risk: an interrupted session just means the human starts over, since no file has been touched yet. The risk window opens once `CLAUDE.md` and/or `AGENTS.md` are deleted and closes only when setup finishes regenerating them. If the session or process ends anywhere in that window, not just when setup itself reports a clean failure, the repo is left in a genuinely degraded state: one or both boot files missing, with no error message walking the human on the loop through it, because nothing printed a report before the interruption happened.

Recovery relies on the same flags-used marker file this feature adds to `setup.sh`/`setup.ps1` (see Data Ownership below), which doubles as the retry cache: it holds the reconstructed and confirmed flags plus the attempted command, written to disk so it survives a killed process, not held only in the conversation. On return, the human on the loop sees the missing boot files directly in the repo, re-invokes the refresh skill, and the skill reads that marker file instead of repeating detection, showing the same flag-by-flag confidence report for a fresh confirmation and then re-running the attempted command. If the marker file itself is missing (the interruption landed before confirmation, or the file was never written), the skill has nothing to read and falls back to full detection, the same as a first run.

---

## Acceptance Criteria

- [ ] Skill takes the target tool as input (named by the human on the loop up front), or asks which tool if the repo has more than one tool installed and none was named
- [ ] Skill detects the named tool's install across all tools `setup.sh`/`setup.ps1` support, and `setup.ps1`'s equivalents
- [ ] Skill reconstructs the active flag set from hook wiring and marker files, reporting confidence per flag
- [ ] Skill halts for human confirmation when any flag's reconstruction is ambiguous or partial, before running setup
- [ ] Skill deletes only `CLAUDE.md`/`AGENTS.md`, never `settings.local.json` or other user-owned files
- [ ] Skill re-invokes the correct setup script with the confirmed flags
- [ ] If the re-invoked setup script fails partway through, the skill stops immediately (no auto-retry), investigates the likely cause (lock/permission/held-by-process), reports which step it reached, prints the exact attempted command as a copyable code block, and caches the reconstructed flags/command so a retry does not repeat detection
- [ ] If no supported tool install exists at all in the repo (for the named tool, or for any tool if none was named), the skill reports this and stops rather than attempting a refresh
- [ ] `setup.sh` and `setup.ps1` both write a flags-used marker file at install time, in parity with each other
- [ ] The refresh skill writes the confirmed flags and attempted command to the same marker file before deleting any boot file, so an interrupted session (process killed mid-refresh) can be recovered on the next invocation without repeating detection
- [ ] If `CLAUDE.md`/`AGENTS.md` are found missing with no completed refresh (an interrupted prior run), the skill reads the marker file, reports the recovered state, and offers to resume rather than starting a fresh detection pass

---

*This brief will be read by the orchestrator skill. See [planifest/skills/orchestrator/SKILL.md](../skills/orchestrator/SKILL.md)*
