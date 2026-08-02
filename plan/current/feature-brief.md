---
title: "Feature Brief - Orchestrator Redundancy Removal"
summary: "Remove duplicated, misplaced, and expository content from the orchestrator skill so every rule is stated in exactly one canonical place."
status: "draft"
version: "0.1.0"
---
# Feature Brief - Orchestrator Redundancy Removal

**Feature ID:** 0000022-orchestrator-redundancy-removal

## Business Goal

Reduce `planifest-framework/skills/planifest-orchestrator/SKILL.md` from 10,379 words to at most 7,600 by removing content whose canonical statement already lives (or will live) elsewhere, with zero behavioural change. The orchestrator is loaded in full before any work begins in every session; every duplicated word degrades instruction adherence and costs tokens on every run. This is a de-duplication pass, distinct from and preparatory to the structural router decomposition deferred in backlog 0000020.

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| Remove content duplicated in phase skills, workflows, and standards (Class 1) | As the human on the loop, I want each pipeline rule stated in exactly one canonical file, so that the orchestrator and its phase skills can never drift apart. | must-have | 1 |
| Relocate reference data to standards files (Class 2) | As the orchestrator agent, I want the model-tier table and parallelism/dispatch guidance in a standards file loaded at need, so that always-loaded context shrinks and stale model ids are maintained in one place. | must-have | 1 |
| Trim exposition and update regression tests relocation-aware (Class 3) | As the framework maintainer, I want explanatory asides removed and content-pinning regression tests updated to assert the new canonical locations, so that the trim is verified lossless. | must-have | 1 |

## Waves

Single wave. Three features, one pipeline run.

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Standards, skills, hooks, and setup scripts enforcing the confirmed-design pipeline |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| none | n/a | n/a |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| planifest-orchestrator SKILL.md | phase skills, workflows, standards, templates | file pointers (load-on-need) | Each removed instruction remains stated in exactly one canonical file that is already loaded at the moment it is needed |

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown (skill/standards files); Bash (regression tests) |
| Runtime | n/a |
| Framework | Planifest skill/standards conventions |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | `planifest-framework/tests/regression/` pack (22 tests) |
| IaC | none |
| Cloud | none |
| Compute | n/a |
| CI | local regression pack run |
| Build target | local |

## Scope Boundaries

### In Scope

- Class 1 removals from the orchestrator: telemetry event table and JSON snippets; per-phase Input/Produces/Gate blocks (P1-P7); Fast Path criteria and execution; Scope Lock suggested-answer protocol detail; reversal execute/assess mechanics; retrofit scan and per-mode discovery content; Change Pipeline confirm questions; triple-stated "load the phase skill" rows in the Framework Index
- Class 2 relocations: Model Tier Decision Table and Parallelism Rules + Agent Dispatch Template move to standards file(s); orchestrator, ship-agent, and codegen-agent point to the new canonical location
- Class 3 trims: expository asides in Hard Limits and P0 coaching prose
- Relocation-aware updates to regression tests that pin orchestrator phrases scheduled for removal or relocation
- Regression-pack baseline run before edits and comparison re-run after (0000021 ADR-002)
- Documentation updates: `component.yml` version bump, component registry, `docs/about.md` (at ship)

### Out of Scope

- Structural router decomposition of the orchestrator into `references/` (backlog 0000020)
- Any change to phase-skill behaviour, hook `.mjs` logic, or `setup.sh`/`setup.ps1`
- All other open backlog entries (0000020 through 0000028)
- Changes under `.claude/` (synced copy, refreshed via setup)
- New enforcement mechanisms (e.g. word-count test; that belongs to 0000020)

### Deferred

- Nothing deferred

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Orchestrator size | <= 7,600 words | `wc -w` on SKILL.md after final commit |
| Behavioural change | zero | Full regression pack green before and after; diff review confirms every removed instruction has exactly one canonical statement |
| Enforcement-content loss | zero | 0000021 ADR-002 baseline comparison |

## Constraints and Assumptions

### Constraints

- 0000021 ADR-002: baseline-gated trim process is mandatory
- Ratchet: content-pinning regression tests are updated to assert new canonical locations, never deleted or weakened
- Local git only (`custom-001-local-git-only.md`) with a per-session exception: the human on the loop expressly authorised the agent to push and raise the PR for this run (grant recorded in the P0 build log)
- No em dashes in artifacts; "human on the loop" phrasing

### Assumptions

- The word estimates in the findings table (2,900-3,300 removable) are approximate; the 7,600-word ceiling is the binding target, not the per-section estimates
- A new standards file is an acceptable home for model-tier and parallelism content (naming decided at P2 via ADR)

## Scenario Paths

**Happy path:** Baseline regression run recorded; Class 1-3 edits applied section by section with granular commits; affected regression tests updated relocation-aware; full pack re-run green; word count at or under 7,600; docs updated; the agent pushes the feature branch and raises the PR at P9 (per-session grant recorded in the build log).

> Baseline, edit, re-verify, ship with agent-raised PR.

**First-run path:** Before any edit to SKILL.md: run the full regression pack and record pass/fail per test plus the current word counts (orchestrator and skills corpus total) in `plan/current/regression-baseline.md`. No edit lands before the baseline is committed.

> Baseline artifact exists and is committed before the first trim commit.

**Error / sad path:** A regression test fails after an edit because it pinned a removed phrase. Resolution: if the phrase was relocated, update the test to assert the new canonical location; if the phrase was the sole statement of a rule, restore it (the cut was wrong). A test is never deleted or weakened to make the pack pass. If the same test fails after 2 correction attempts, stop and escalate to the human on the loop. Because only 4 of the 22 tests pin orchestrator content, the P4 diff review is the named second detector: a lost rule found by diff review resolves identically to a test failure (restore the content, never rationalise the cut).

> Two detectors: red tests for pinned content, P4 diff review for everything else; both resolve by relocation-aware update or restoration, never by weakening.

**Cross-session continuity:** All durable run state lives in committed artifacts (`plan/current/`, granular commits per section edit); the branch is pushed at phase gates, so the remote also holds gate state. The session markers (`plan/.orchestrator-active`, `plan/.orchestrator-ack`, `plan/.run-mode`) are committed alongside the P0 artifacts, so run mode survives a lost working tree. An interrupted session resumes from the last commit; `regression-baseline.md` is committed early so the comparison target survives any interruption. No partial-write risk beyond a single uncommitted file edit, which git status surfaces on resume.

> Resume from last granular commit; baseline and markers are durable.

## Acceptance Criteria

- [ ] `planifest-framework/skills/planifest-orchestrator/SKILL.md` is at most 7,600 words with all Class 1, 2, and 3 items from the findings table addressed
- [ ] Every removed instruction is verifiably stated in exactly one canonical file (phase skill, workflow, standard, or template), confirmed by diff review at P4
- [ ] Model-tier and parallelism/dispatch guidance live in standards file(s); orchestrator, ship-agent, and codegen-agent reference the canonical location instead of restating it
- [ ] Full regression pack passes before edits (baseline) and after (comparison); content-pinning tests updated relocation-aware, none deleted or weakened
- [ ] `component.yml`, component registry, and changelog reflect the change at ship
