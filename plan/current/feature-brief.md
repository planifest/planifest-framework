---
title: "Feature Brief - agent-optimisation"
summary: "Two optimisations: explicit Docker build target awareness in the pipeline, and an on-demand skill that identifies superfluous content in Planifest skill files."
status: "approved"
version: "0.1.0"
---
# Feature Brief - agent-optimisation

**Feature ID:** 0000007-agent-optimisation

---

## Business Goal

Agents waste time checking host-installed runtimes when the build target is Docker — those checks are irrelevant and can cause false failures or wrong decisions. Separately, Planifest skill files contain content that is already implicit model knowledge, already enforced by hooks, or repeated verbatim across files — every token loaded needlessly increases cost and context pressure. Both problems are fixed by making intent explicit and removing dead weight.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| Build target field | As a developer, I declare `Build target: docker` in my stack so agents never check host runtimes when building in Docker | must-have | 1 |
| Build target agent guidance | As an agent, I read `Build target` from the design and adjust my environment assumptions accordingly | must-have | 1 |
| Optimise agent | As a developer, I invoke `planifest-optimise-agent` on demand and receive one suggestion at a time for removing superfluous content from Planifest skill files; I confirm or reject each; confirmed items become requirements | must-have | 1 |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Skills, templates, standards |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown (skills/templates/standards), Bash |
| Testing | Bash assert (existing harness) |

---

## Scope Boundaries

### In Scope
- New `Build target: local \| docker \| ci-only` row in `feature-brief.template.md` stack table
- Orchestrator P0 coaching: prompt human to set Build target when compute/IaC implies Docker
- Codegen-agent guidance: when `Build target: docker` — never check host runtimes; scaffold Dockerfile-first; run checks via `docker build`/`docker run`
- Validate-agent guidance: when `Build target: docker` — run CI checks inside container, not against host
- New `standards/build-target-standards.md` defining all three tiers and per-tier agent behaviour
- New `planifest-optimise-agent` skill:
  - Targets Planifest framework skill files only (`planifest-framework/skills/`)
  - Identifies: implicit model knowledge stated explicitly; instructions duplicated from hook enforcement; boilerplate repeated verbatim across skills; sections with no unique signal
  - Presents one suggestion at a time in chat; human confirms or rejects
  - Accumulates confirmed items into a numbered list
  - At the end: produces a summary of confirmed changes as input to a Change Pipeline run
- Tests covering all new requirements

### Out of Scope
- Applying confirmed optimisations (that is a separate Change Pipeline run)
- Reviewing `planifest-overrides/capability-skills/` (user-owned)
- Automated removal of content without human confirmation
- Reviewing workflow files (`.claude/commands/`, `.github/copilot-workflows/`) — skills only

### Deferred
- Optimise-agent reviewing workflow files (can be added in a later change)

---

## Acceptance Criteria

- [ ] `feature-brief.template.md` stack table includes `Build target` row with options `local | docker | ci-only`
- [ ] Orchestrator skill coaches human to declare Build target at P0
- [ ] Codegen-agent skill has explicit `Build target: docker` behaviour section
- [ ] Validate-agent skill has explicit `Build target: docker` behaviour section
- [ ] `standards/build-target-standards.md` exists with all three tier definitions
- [ ] `planifest-optimise-agent/SKILL.md` exists with correct frontmatter
- [ ] Optimise-agent presents one suggestion at a time and waits for human confirm/reject
- [ ] Optimise-agent produces a confirmed-changes summary at the end
- [ ] Tests cover all requirements
