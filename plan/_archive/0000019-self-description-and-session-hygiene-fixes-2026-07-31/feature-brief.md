---
title: "Feature Brief - self-description-and-session-hygiene-fixes"
summary: "The business case, scope, and product requirements for the feature."
status: "approved"
version: "0.1.0"
---
# Feature Brief - self-description-and-session-hygiene-fixes

**Feature ID:** 0000019-self-description-and-session-hygiene-fixes

> Derived from `plan/backlog/` entries (external framework review + ad-hoc filings), confirmed with the human in chat rather than authored fresh. Coaching gaps were resolved conversationally; recorded here for the record the orchestrator protocol expects.

---

## Business Goal

The framework's own self-description has drifted from the repository it describes — wrong README counts, wrong paths, a `component.json`/`component.yml` mismatch that falsely rejects valid changes, an overclaimed CI parity guarantee, and an unfalsifiable Hard Limit. A specification-accuracy framework whose own specification is inaccurate undercuts the pitch in a reader's first thirty seconds. Separately, three session-hygiene gaps (confirmation timestamps, context-window hygiene, backlog ID convention) were identified as worth fixing alongside.

---

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| 0000014 readme-accuracy | As a framework maintainer, I want README counts/paths/structure correct, so that a reader's first check doesn't fail | must-have | 1 |
| 0000015 component-yml-matcher | As a repo adopter, I want the shipped hooks to match `component.yml`, so that a correct change isn't falsely rejected | must-have | 1 |
| 0000016 honest-parity-wording | As a framework maintainer, I want the CI parity guarantee described accurately, so that it isn't oversold | must-have | 1 |
| 0000017 reword-hard-limit-1 | As a framework maintainer, I want Hard Limit 1 to state enforceable behaviour, so that it's falsifiable | must-have | 1 |
| 0000018 self-description-ci-check | As a framework maintainer, I want CI to catch future README drift automatically, so that 0000014 doesn't recur | must-have | 1 |
| 0000011 confirmation-timestamp | As a human running a session, I want design confirmations timestamped, so that same-day iterations are disambiguated | should-have | 1 |
| 0000012 context-clear-compaction | As a human running a long session, I want context cleared/compacted at phase boundaries, so that the session doesn't degrade | should-have | 1 |
| 0000026 backlog-id-convention-docs | As an agent filing a backlog entry, I want the ID sequence convention documented, so that I don't have to reverse-engineer it | should-have | 1 |
| 0000027 context-pressure-phase-fix | As a framework maintainer, I want telemetry emission to actually succeed, so that observability isn't silently broken | must-have | done (fixed in P0) |

---

## Waves

Single wave — human directive overriding the initial multi-wave split recommendation. All 9 items ship together; only internal sequencing (0000018 after 0000014) applies.

| Wave | Features Included | Ships When |
|------|-------------------|------------|
| 1 | 0000011, 0000012, 0000014, 0000015, 0000016, 0000017, 0000018, 0000026 (0000027 already shipped in P0) | All 8 remaining items pass P4 validation and P5 security review |

---

## Target Architecture

### Components

No new components — all changes are edits to existing framework-authoring files (README, CI workflow, shipped hooks, orchestrator skill, backlog template) plus one new CI script (0000018).

### Data Ownership

Not applicable — no data-owning components.

### Integration Points

Not applicable.

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown, YAML, bash, Node (existing hook language) |
| Runtime | N/A |
| Framework | N/A |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | existing `planifest-framework/tests/` shell-script convention |
| IaC | none |
| Cloud | none |
| Compute | none |
| CI | GitHub Actions (existing `.github/workflows/planifest.yml`) |
| Build target | ci-only |

---

## Scope Boundaries

### In Scope
- 0000011, 0000012, 0000014, 0000015, 0000016, 0000017, 0000018, 0000026, 0000027

### Out of Scope
- 0000013 (setup refresh skill) — deferred to next release, not discarded

### Deferred
- 0000019 (populate regression pack), 0000020 (decompose orchestrator — depends on 0000019), 0000021 (minimal artifact set — needs human judgement), 0000022/0000023 (token accounting / baseline comparison — sequenced pair), 0000024 (skill-scope ADR), 0000025 (adoption position). None blocked by this batch.

---

## Non-Functional Requirements

Not applicable — no runtime component. See design.md Architecture Layer for the explicit N/A reasoning.

---

## Constraints and Assumptions

### Constraints
- `planifest-overrides/instructions/custom-001-local-git-only.md` — local-git-only by default; this session has an explicit human grant for fetch/push/PR use.

### Assumptions
- See design.md `## Assumptions` — component.json regex is over-strict not a hole; docs/about.md 0.18.0 is the correct version baseline; context-pressure→"orchestrator" phase mapping is semantically correct.

---

## Scenario Paths

**Happy path:** All 9 fixes land across README, CI workflow, hooks, orchestrator SKILL.md, backlog template, and the telemetry hook; validation passes; changes are committed and shipped as 0000019.

**First-run path:** Not applicable — these are corrections to existing files, no first-run state to initialise.

**Error / sad path:** If a CI/hook regex change breaks the parity check for real repos using it, the two new tests in 0000015 (pass case + fail case, run against the shipped hooks directly, not just the workflow) catch it before ship.

**Cross-session continuity:** `plan/current/build-log.md` and `pause.md` carry state if interrupted; resuming re-loads discovery/design and continues from the last committed item.

---

## Acceptance Criteria

- [ ] README table has no Count column, folders described by category, both structure-diagram paths resolve to real paths (0000014)
- [ ] All `component.json` matchers/strings in CI + shipped hooks read `component.yml`; two new tests pass (0000015)
- [ ] CI/hook failure messages and README describe the parity check as a presence heuristic, not a correspondence guarantee (0000016)
- [ ] Hard Limit 1 states enforceable, falsifiable behaviour; orchestrator wording aligned (0000017)
- [ ] New repository-scoped CI script verifies structure-diagram paths and folder-table coverage, runs on PR (0000018)
- [ ] Design confirmation format includes local timestamp + timezone, `//`-delimited (0000011)
- [ ] Orchestrator issues `/clear` at Phase 0 start and P9 completion (or prompts if unsupported); dynamic compaction monitoring added (0000012)
- [ ] Backlog ID sequence convention documented in template and orchestrator P0 step (0000026)
- [x] `context-pressure.mjs` sends a valid `phase` enum value; verified against running backend (0000027 — done)

---

*This brief will be read by the orchestrator skill. See [planifest/skills/orchestrator/SKILL.md](../../.claude/skills/planifest-orchestrator/SKILL.md)*
