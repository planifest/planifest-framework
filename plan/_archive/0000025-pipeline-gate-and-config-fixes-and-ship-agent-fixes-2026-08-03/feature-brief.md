---
title: "Feature Brief - pipeline-gate-and-config-fixes-and-ship-agent-fixes"
summary: "The business case, scope, and product requirements for the feature."
status: "approved"
version: "0.1.0"
---
# Feature Brief - pipeline-gate-and-config-fixes-and-ship-agent-fixes

**Feature ID:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes

## Business Goal

Reduce operator friction and correctness risk in the Planifest pipeline itself, by fixing seven small, independently-discovered defects surfaced through real pipeline runs (this repo's own 0000016/0000023/0000024 sessions, plus two filed upstream by a downstream adopter). Each is small enough to be a Fast Path/Change candidate on its own, but together they touch the same component (`planifest-framework`) and the same underlying pattern — phase skills and process tooling not respecting session/run state or configuration conventions the framework has already established elsewhere.

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| Ship-agent PR footer | As a human on the loop, I want the ship-agent's PR description template to omit the AI-attribution footer by default, so that I don't have to manually strip it from every PR. | should-have | 1 |
| Ship-agent archive commit | As a human on the loop, I want the P7 archive commit's `git add` to explicitly name `plan/current/`, so that the archive commit doesn't silently depend on git's rename-detection heuristic to pick up the copy-then-delete. | must-have | 1 |
| Subagent parallelism expansion | As a human on the loop, I want independent, non-cross-referencing writes across all pipeline phases (not just P1/P3) dispatched in parallel subagents, so that pipeline wall-clock time drops without changing output quality. | should-have | 1 |
| Setup config relocation | As a human on the loop, I want the active setup flags/backend-url to live in a versioned `planifest-overrides/setup-config/` file (one per AI tool), so that setup configuration is tracked and survives like the rest of overrides instead of only existing in a gitignored tool-specific marker. | should-have | 1 |
| Backlog unification for deferred items | As a human on the loop, I want `recommendations.md`'s Deferred Items and Tech Debt tables routed into `plan/backlog/` (tagged by source), so that deferred work is centrally discoverable instead of scattered across each archived feature's own docs. | should-have | 1 |
| docs-agent continuous_run respect | As a human on the loop, I want `planifest-docs-agent`'s P6 Gate B (and any other phase-skill-internal confirmation gate with the same pattern) to check `plan/.run-mode`/`continuous_run` before stopping for confirmation, so that a continuous-run session isn't interrupted by redundant per-step prompts a session-level choice already answered. | should-have | 1 |
| Scope Lock default-drafted, batch-presented answers | As a human on the loop, I want the Scope Lock Challenge to always draft all four scenario-path answers up front (via the existing `planifest-scope-lock-agent` subagent, dispatched in parallel) and present them together for one batch accept/edit/reject pass, so that I'm not asked a blank open question at each step and don't have to complete four separate round-trips to confirm scope. | should-have | 1 |

## Waves

Single wave — all seven stories are small, same-component (`planifest-framework`) fixes with no cross-dependencies; the human confirmed one pipeline run at P0 rather than splitting into waves, despite exceeding the usual ≤3-story rule of thumb.

## Target Architecture

The agent implements within these constraints - it does not choose the architecture.

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Core standards, skills, hooks, and setup scripts enforcing the confirmed-design pipeline — all seven stories are changes to this component's skills/standards/scripts |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| None — this feature changes skill/process behavior and setup configuration, not application data | n/a | n/a |

### Integration Points

None — no cross-component calls introduced or changed.

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown (skills/standards), Node.js (`.mjs` hooks/scripts), Bash (setup scripts, regression tests) — inherited, no new stack choice |
| Runtime | Node (hooks/scripts), POSIX shell (setup, tests) |
| Framework | none |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | Bash regression test scripts (`planifest-framework/tests/`) |
| IaC | none |
| Cloud | none |
| Compute | none |
| CI | GitHub Actions |
| Build target | local |

## Scope Boundaries

### In Scope
- `planifest-ship-agent/SKILL.md`: remove hardcoded AI-attribution footer from the P9 PR description template (both `gh pr create` and human-push output paths); default off, design a toggle if adopters may want it back
- `planifest-ship-agent/SKILL.md`: fix P7 Step 7's `git add` to explicitly name `plan/current/` rather than relying on git rename-detection
- Orchestrator's Parallelism Rules / Agent Dispatch Template (and relevant phase skills): extend the "MUST parallelise independent writes" pattern already used at P1/P3 to other phases with independent, non-cross-referencing writes (e.g. P4 test files, P6 living-doc edits)
- Setup scripts (`setup.sh`/`setup.ps1` and tool adapters): write active flags/backend-url to `planifest-overrides/setup-config/{tool}.md` (or equivalent), in addition to or replacing the existing gitignored `.planifest-setup-flags` marker
- `recommendations.md` template/agent behavior: route Deferred Items and Tech Debt entries into `plan/backlog/{id}-{slug}/` tagged with their source feature, instead of (or alongside) the existing recommendations.md tables
- `planifest-docs-agent/SKILL.md` P6 Gate B: check `plan/.run-mode`/`continuous_run` before stopping for confirmation; audit other phase skills (spec-agent, adr-agent, codegen-agent, etc.) for the same internal-gate pattern and fix any found
- `planifest-orchestrator/SKILL.md` Scope Lock Challenge protocol + `0000017-ADR-003`: change default to always-draft-and-batch-present (via `planifest-scope-lock-agent`, dispatched in parallel across the four questions), human does one batch accept/edit/reject pass instead of four sequential opt-in round-trips; new ADR superseding/amending `0000017-ADR-003`, scoped narrowly so it doesn't read as reversing `0000014-ADR-008`'s one-question-at-a-time convention framework-wide

### Out of Scope
- Any change to `structured-telemetry-mcp` or other external MCP servers
- New capability skills or new components
- The 12 other backlog items reviewed at P0 and left for future runs (0000020, 0000021, 0000022, 0000023, 0000024, 0000025 backlog items, 0000026, 0000034, 0000035)
- Retroactively rewriting already-archived features' `recommendations.md` files to backfill the backlog-unification pattern (0000038's scope is the mechanism going forward, not a data migration)

### Deferred
- Whether the PR-footer toggle (if built) should default to a `planifest-overrides/instructions/` file or a simpler hardcoded removal — left for the P1 spec-agent / P2 ADR to decide with the human, per the backlog entry's own note that this is "a design decision for whoever picks this up"
- Nothing else deferred — Scope Lock Challenge to confirm

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Latency | not applicable | this feature changes pipeline tooling, not a runtime service |
| Availability | not applicable | n/a |
| Throughput | not applicable | n/a |
| Pipeline efficiency | 100% of phase batches with 2+ independent, non-cross-referencing writes dispatch in parallel | `Parallel task batches` field already tracked per phase in `build-log.md` |
| Security | no new attack surface — all changes are to trusted, human-reviewed skill/script files in this repo | n/a |

## Constraints and Assumptions

### Constraints
- Local Git Only (repo instruction): no remote git operations without explicit human request
- Commit Granularly, Continuously (repo instruction): each story's fix is its own commit
- Prefer Subagent Decomposition (repo instruction): directly relevant to the 0000036 story — codegen for these seven stories should itself follow the pattern being fixed

### Assumptions
- The 0000040/0000041 downstream-filed backlog entries reflect real friction in a genuine Planifest deployment, not a formatting artifact — impact if wrong: the two stories they inform (docs-agent continuous_run, Scope Lock defaults) would be solving a non-problem, but both are also independently confirmed by this repo's own history (0000029 was filed by feature 0000016 in this same repo) and by the human's direct confirmation at P0, so impact is low even if the downstream framing is imperfect

## Scenario Paths

**Happy path:** A human runs the Planifest pipeline in continuous mode after this feature ships. The ship-agent's PR output has no attribution footer and the P7 archive commit correctly stages `plan/current/` every time regardless of git's rename heuristics. Independent phase writes dispatch in parallel. Setup config is readable from `planifest-overrides/setup-config/`. A newly-archived feature's deferred items land directly in `plan/backlog/`. docs-agent's Gate B and the Scope Lock Challenge both respect the human's continuous-run choice — Scope Lock presents four drafted answers in one batch for accept/edit/reject, and Gate B proceeds with a logged statement instead of stopping.

**First-run path:** No first-run/bootstrap concern — these are behavioral fixes to existing skill files and scripts, not new state. The one exception is `planifest-overrides/setup-config/`, which does not exist yet in this repo; its first creation is part of the 0000037 story itself (analogous to how `product.yml` was first created in 0000023 per the existing precedent in this repo's history).

**Error / sad path:** If the Scope Lock draft-and-batch flow's parallel subagent dispatch fails for one of the four questions, present the three successful drafts plus a clear failure marker for the fourth, falling back to the original blank-question flow for that one item only rather than blocking the whole batch. If `planifest-overrides/setup-config/` write fails (e.g. permissions), setup falls back to the existing `.planifest-setup-flags`-only behavior and surfaces a warning rather than aborting setup.

**Cross-session continuity:** All seven fixes are stateless skill/script/template changes — no runtime state to recover mid-fix. The one exception is 0000037 (setup config relocation): if setup is interrupted after writing `planifest-overrides/setup-config/{tool}.md` but before `.planifest-setup-flags`, the next refresh/setup run must treat the overrides file as authoritative and reconcile, not silently duplicate or conflict.

## Acceptance Criteria

- [ ] Ship-agent PR output (both `gh pr create` and human-push description) contains no hardcoded AI-attribution line by default
- [ ] Ship-agent P7 Step 7's archive commit explicitly stages `plan/current/` in its `git add` invocation
- [ ] Orchestrator/phase-skill dispatch guidance documents parallel dispatch for independent writes beyond P1/P3 (at minimum P4 and P6, per the 0000036 backlog entry's own worked example)
- [ ] `planifest-overrides/setup-config/{tool}.md` (or equivalent) is written by setup scripts and takes effect on refresh, without breaking existing `.planifest-setup-flags`-only projects
- [ ] Deferred items from a feature's `recommendations.md` are written to `plan/backlog/{id}-{slug}/` tagged with their source feature, discoverable at the next P0's backlog pickup
- [ ] `planifest-docs-agent` P6 Gate B checks `continuous_run` before stopping for confirmation; at least the audited-and-confirmed other phase skills with the same pattern are fixed too
- [ ] Scope Lock Challenge, by default, drafts all four scenario-path answers up front and presents them together for one batch accept/edit/reject pass; a new ADR records the change and its scoped relationship to `0000017-ADR-003` and `0000014-ADR-008`
