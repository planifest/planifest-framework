---
title: "Feature Brief - build-assessment-phase"
summary: "Add Phase 8 (Build Assessment) to the Planifest pipeline, with a build log working file and model/parallelism routing improvements."
status: "approved"
version: "0.1.0"
---
# Feature Brief - build-assessment-phase

**Feature ID:** 0000006-build-assessment-phase

---

## Business Goal

Pipeline runs produce no structured record of how efficiently they ran — which models were used, which tasks ran in parallel, how many agents were spawned. This makes it impossible to review or improve build efficiency over time. Adding a Phase 8 Build Assessment creates an automatic, filed report for every pipeline run, and the model routing and parallelism fixes ensure there is something worth measuring.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| Build log working file | As an orchestrator, I maintain a working build log throughout the run so build telemetry survives session changes | must-have | 1 |
| P8 Build Assessment phase and skill | As a framework user, I get a filed build report in the archive for every completed pipeline run | must-have | 1 |
| Model routing in orchestrator | As an orchestrator, I make an explicit model-tier decision when spawning every subagent | must-have | 1 |
| Parallelism directives | As an orchestrator and phase agent, I parallelise independent tasks explicitly and by default | must-have | 1 |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Pipeline orchestration, skills, hooks, templates |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| planifest-orchestrator | planifest-build-assessment-agent | skill invocation | Passes build-log.md path |
| planifest-ship-agent | P8 trigger | instruction | Calls P8 before archiving |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown (skills/templates), Bash, PowerShell |
| Testing | Bash assert (existing test harness) |
| CI | GitHub Actions (existing) |

---

## Scope Boundaries

### In Scope
- `plan/current/build-log.md` — working file created at P0, updated at each phase boundary by the orchestrator
- `planifest-build-assessment-agent` — new P8 skill that reads build-log.md and produces a structured report
- Report filed to `plan/archive/{feature-id}-{date}/build-report.md` at P7 ship
- Model routing rules in orchestrator skill: complex work → primary model tier; routine tasks (search, grep, simple file reads) → cheaper model tier; tool-agnostic (expressed as tiers, not model names)
- Parallelism directives: explicit rules in orchestrator and phase skills for when tasks MUST be parallelised
- Build log template at `planifest-framework/templates/build-log.template.md`
- Tests covering: build-log creation, P8 skill existence, model routing instructions present in orchestrator, parallelism directives present in skills

### Out of Scope
- Automated model cost tracking or billing integration
- Runtime enforcement of model tier selection (honour-system in skill instructions)
- Changes to setup.sh / setup.ps1

### Deferred
- Aggregated build reports across multiple pipeline runs

---

## Acceptance Criteria

- [ ] `plan/current/build-log.md` is created at P0 and updated at each phase boundary
- [ ] `planifest-build-assessment-agent` skill exists with correct YAML frontmatter
- [ ] P8 is documented in the orchestrator phase table and response prefix convention
- [ ] Orchestrator skill contains explicit model-tier decision rules with a decision table
- [ ] Orchestrator skill contains explicit parallelism directives
- [ ] Phase skills (spec, adr, codegen, validate, security, docs, ship) contain parallelism directives where applicable
- [ ] build-log.template.md exists in templates/
- [ ] All new requirements covered by tests in test-0000006-build-assessment.sh
