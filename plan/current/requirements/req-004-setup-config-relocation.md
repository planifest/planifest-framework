---
title: "Requirement: req-004 - setup config relocation"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-004 - setup config relocation

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source:** US-004
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want the active setup flags/backend-url to live in a versioned `planifest-overrides/setup-config/` file, so that setup configuration is tracked and survives like the rest of overrides.

## Functional Requirements
- `planifest-overrides/setup-config/` MUST exist as a new directory, holding one file per supported AI tool (e.g. `setup-config/claude-code.md`), analogous to the existing `instructions/`, `capability-skills/`, and `library-standards/` subdirectories under `planifest-overrides/`.
- Each per-tool file MUST record the same shape of information currently held in that tool's gitignored `{tool-dir}/.planifest-setup-flags` marker — at minimum `flags` (the active `--flag` list, e.g. `--context-mode-mcp`, `--structured-telemetry-mcp`, `--strict-orchestrator`) and `backendUrl`.
- `setup.sh` and `setup.ps1` MUST write to the relevant tool's file under `planifest-overrides/setup-config/` as part of a normal setup run, in addition to (not instead of) the existing gitignored `{tool-dir}/.planifest-setup-flags` marker.
- `planifest-overrides/setup-config/` and its per-tool files MUST NOT be gitignored — they are tracked, versioned config, unlike the existing marker file.
- If the write to `planifest-overrides/setup-config/` fails (e.g. permissions), setup MUST fall back to the existing `.planifest-setup-flags`-only behavior and surface a warning rather than aborting setup (per feature-brief.md's sad path).

## Acceptance Criteria
- [ ] `planifest-overrides/setup-config/` exists as a directory alongside `planifest-overrides/instructions/`, `capability-skills/`, and `library-standards/`.
- [ ] Running `setup.sh` (or `setup.ps1`) for a given AI tool writes one file for that tool under `planifest-overrides/setup-config/` (e.g. `setup-config/claude-code.md`) recording the active flags and `backendUrl` in effect for that run.
- [ ] The written per-tool file is not covered by `.gitignore` and shows up as trackable/committable in `git status`.
- [ ] The existing gitignored `{tool-dir}/.planifest-setup-flags` marker continues to be written by setup scripts and is not removed by this change.
- [ ] A setup run on a repo that has no `planifest-overrides/setup-config/` yet creates it and the per-tool file without erroring (first-run/bootstrap case).
- [ ] If the write to `planifest-overrides/setup-config/` fails, setup completes using the existing `.planifest-setup-flags`-only behavior and prints a warning, rather than aborting.

## Dependencies
- `planifest-overrides/` directory structure and its existing setup.sh-reads-but-never-writes convention (ADR-002, 0000005-framework-governance) — this requirement adds a new setup.sh-writes exception to that directory, which the P2 ADR step should reconcile explicitly.
- Exact reconciliation behavior when both `planifest-overrides/setup-config/{tool}.md` and the gitignored `.planifest-setup-flags` marker exist and disagree (precedence, conflict handling, and whether this extends to `.orchestrator-strict`) is undecided per the originating backlog entry (`plan/backlog/0000037-relocate-setup-config-to-overrides/entry.md`) and is deferred to the P2 ADR for this feature, not resolved here.
- `planifest-refresh-setup` skill's Step 2/3 flag-inference logic — out of scope for this requirement's acceptance criteria, but a likely consumer of the new file once it exists.
