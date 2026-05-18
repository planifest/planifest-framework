---
title: "Feature Brief - docs-restructure-commit-directives"
summary: "Framework docs split into three files; P9 Ship phase added; build log, run-mode sentinel, phase-numbering, P0 pre-flight, and git tagging added to the orchestrator and ship-agent."
status: "approved"
version: "0.2.0"
---
# Feature Brief - docs-restructure-commit-directives

**Feature ID:** 0000012-docs-restructure-commit-directives

---

## Business Goal

The Planifest framework had several structural problems: monolithic docs with no clear ownership, inconsistent `plan/_archive` references, build logs skipped leaving P8 with nothing to analyse, run mode not persisted, agents citing invented phase numbers, no formal shipping phase, and no branch pre-flight at pipeline start. This feature restructures docs into three purpose-specific files, formalises the pipeline as P0–P9 (adding P9 Ship), enforces build log completeness and run-mode persistence, adds a P0 pre-flight check, introduces git tagging at ship time, and produces a migration for retroactive release tags.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| Docs three-file restructure | As a framework user reading getting-started.md, I see a lean 5-step onboarding guide, so that I can set up Planifest without wading through operational detail | must-have | 1 |
| Docs three-file restructure | As a framework user reading pipeline-reference.md, I find comprehensive step-by-step phase guidance, so that I have a single authoritative reference for the full pipeline | must-have | 1 |
| Docs three-file restructure | As a framework user reading project-operations.md, I find a concise ops reference, so that I can manage running projects without re-reading the full pipeline | must-have | 1 |
| Incremental plan commits | As a pipeline agent, I commit plan/current/ at each phase gate, so that design evolution is preserved in git history incrementally rather than only at P7 | must-have | 1 |
| Build log enforcement | As a pipeline agent, I write a build log entry at every phase start and gate, so that P8 always has complete data to analyse | must-have | 1 |
| Run-mode sentinel | As a pipeline orchestrator, I write a run-mode sentinel file at P0 and record explicit human acceptance at each interactive phase gate, so that the run mode and gate acceptance history are permanently recorded | must-have | 1 |
| Phase structure P0–P9 | As a pipeline agent, I reference only the canonical phases P0–P9 in all output, so that invented phase numbers never appear and every phase has a defined purpose | must-have | 1 |
| P9 Ship phase | As a pipeline orchestrator at P9, I create a git tag, ask the human whether to push and raise the PR or provide the PR description for them to use, so that the ship action is explicit and flexible | must-have | 1 |
| P0 pre-flight | As a pipeline orchestrator at P0 start, I check the current branch, confirm all previous PRs are merged, and offer to create the feature branch, so that every pipeline run starts from a clean known state | must-have | 1 |
| Retroactive release tags migration | As a repository maintainer, I can run a migration that tags historical merge-to-main commits with their release versions, so that the git history has a complete version tag record | must-have | 1 |

---

## Phases

| Phase | Features Included | Ships When |
|-------|-------------------|------------|
| 1 | All ten features above | All acceptance criteria pass; PR merged |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Framework docs, orchestrator skill, ship-agent, build-assessment-agent, templates, standards |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| plan/current/ | planifest-framework | read by all phase agents |
| planifest-framework/migrations/ | planifest-framework | executed by migrator skill |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| ship-agent (P7) | build-assessment-agent | sub-agent spawn | ship-agent passes archived build-log path; build-assessment-agent returns report path |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown / YAML |
| Runtime | none |
| Framework | none |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | none |
| IaC | none |
| Cloud | none |
| Compute | none |
| CI | none |
| Build target | local |

---

## Scope Boundaries

### In Scope
- Docs three-file restructure: getting-started.md (lean), pipeline-reference.md (detailed), project-operations.md (new ops reference)
- Correct all plan/archive → plan/_archive references
- Commit directive at each phase gate in planifest-orchestrator/SKILL.md
- Build log Hard Limit in planifest-orchestrator/SKILL.md
- Run-mode sentinel protocol (plan/.run-mode + interactive gate acceptance log)
- Pipeline formally P0–P9; P7 renamed Archive, P9 added as Ship
- planifest-orchestrator/SKILL.md: updated phase table (P0–P9), P0 pre-flight section, P9 section
- planifest-ship-agent/SKILL.md: split into P7 Archive + spawn P8 sub-agent + P9 Ship (git tag, push decision, PR description)
- planifest-build-assessment-agent/SKILL.md: clarify invoked by ship-agent as sub-agent
- planifest-framework/pipeline-reference.md: add P9, rename P7 to Archive
- planifest-framework/component.yml: update responsibilities and version
- planifest-framework/migrations/retroactive-release-tags.md: new migration file for historical git tags

### Out of Scope
- Changes to other phase skills (spec-agent, codegen-agent, validate-agent, security-agent, docs-agent)
- Application source code under src/
- CI pipeline configuration
- Schema migrations
- Changes to setup.sh / setup.ps1

### Deferred
- None

---

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Build log completeness | 100% of phases P0–P9 have a log entry | P8 finds no missing phase blocks |
| Phase naming | Zero occurrences of phase numbers outside P0–P9 in orchestrator output | Review of SKILL.md output examples |

---

## Constraints and Assumptions

### Constraints
- All changes local to planifest-framework/ and plan/ — no src/ writes
- Commit message format governed by commit-msg hook (no AI attribution, ≤72-char subject)
- Local git only — no remote push; human pushes and creates PR
- P9 cannot `git push` without human passphrase — agent offers PR description if human opts out

### Assumptions
- Orchestrator and ship-agent SKILL.md edits do not require setup.sh re-run
- build-assessment-agent SKILL.md change is minor (clarification only, no behavioural change)
- Historical merge commits on main are identifiable from git log for the retroactive tags migration

---

## Acceptance Criteria

- [ ] getting-started.md contains steps 1–5 only
- [ ] pipeline-reference.md contains full step-by-step phase guidance including P9
- [ ] project-operations.md exists as a new ops reference file
- [ ] No occurrence of plan/archive (without underscore) in any framework file
- [ ] planifest-orchestrator/SKILL.md phase table lists P0–P9 with P7=Archive, P8=Build Assessment, P9=Ship
- [ ] planifest-orchestrator/SKILL.md has P0 pre-flight check (branch state, PR confirmation, branch creation offer)
- [ ] planifest-orchestrator/SKILL.md has Hard Limit requiring build log entry at every phase
- [ ] planifest-orchestrator/SKILL.md writes plan/.run-mode sentinel at P0 and records gate acceptance in interactive runs
- [ ] planifest-ship-agent/SKILL.md handles P7 Archive, spawns P8 sub-agent, handles P9 Ship
- [ ] P9 creates a local git tag, asks human push/PR preference, outputs PR description if human opts out
- [ ] planifest-build-assessment-agent/SKILL.md clarifies it is invoked as a sub-agent by ship-agent
- [ ] planifest-framework/migrations/retroactive-release-tags.md exists and describes the tagging process
