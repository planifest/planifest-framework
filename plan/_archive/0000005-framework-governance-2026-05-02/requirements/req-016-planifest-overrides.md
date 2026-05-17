---
title: "Requirement: REQ-016 - planifest-overrides"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-016 - planifest-overrides

**Feature:** 0000005-framework-governance
**Source:** planifest-overrides user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- `planifest-overrides/` must exist at the repo root (sibling of `planifest-framework/`), with subdirs: `library-standards/`, `capability-skills/`, `instructions/` — each containing `.gitkeep`
- setup.ps1/setup.sh must never write to, overwrite, or delete any file under `planifest-overrides/`; replacing `planifest-framework/` must not affect `planifest-overrides/` in any way
- `planifest-overrides/instructions/` accepts any number of `.md` files; each file declares one or more repo-specific rules that override or extend core framework behaviour
- planifest-orchestrator SKILL.md must read all `.md` files in `planifest-overrides/instructions/` at P0 start and write their content to `plan/current/design.md` under a `## Repo Instructions` section
- All agents must read `## Repo Instructions` from design.md at phase start and treat each instruction as a hard constraint for the duration of the pipeline run
- If `planifest-overrides/` does not exist, or `planifest-overrides/instructions/` is empty or absent, orchestrator writes `## Repo Instructions: None` — agents proceed without additional constraints; no error, no warning
- Example valid instruction file `planifest-overrides/instructions/git-restrictions.md`: "No git push or git pull. All git operations must be local only (commit, branch, add, reset, log, diff, status)."

## Acceptance Criteria

- [ ] `planifest-overrides/` exists at repo root with all three subdirs and `.gitkeep` files
- [ ] setup.ps1 and setup.sh contain no writes targeting `planifest-overrides/`
- [ ] Orchestrator writes `## Repo Instructions` to design.md at P0 (content from instructions/ files, or "None")
- [ ] All phase SKILL.md files reference `## Repo Instructions` from design.md as a hard constraint source
- [ ] A test instruction file placed in `planifest-overrides/instructions/` is reflected in design.md on next P0

## Dependencies

- REQ-007 (orchestrator-sentinel) — P0 start is when instructions are loaded
- REQ-012 (skill-manifest-in-design) — design.md is the shared state all agents read
