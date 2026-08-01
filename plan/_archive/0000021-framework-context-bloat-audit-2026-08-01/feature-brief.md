---
title: "Feature Brief - Framework Context Bloat Audit"
summary: "The business case, scope, and product requirements for the feature."
status: "approved"
version: "0.1.0"
---
# Feature Brief - Framework Context Bloat Audit

**Feature ID:** 0000021-framework-context-bloat-audit

---

## Business Goal

Planifest's skill and instruction files have accumulated redundant explanation, restated conventions, and spelled-out behavior that current-generation models already infer correctly without being told. This inflates the context every agent loads before doing any real work and crowds out reasoning budget on long pipeline runs. `planifest-orchestrator/SKILL.md` alone is 1,195 lines, roughly 30% of the 3,959 total lines across all 21 skill files.

---

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| Framework Context Bloat Audit | As the human running Planifest pipelines, I want the framework's skill/instruction content audited by a fresh-context Opus 5 agent, so that redundant boilerplate is identified before any edit is made | must-have | 1 |
| Framework Context Bloat Audit | As the human running Planifest pipelines, I want redundant/implicit content trimmed from skills, templates, standards, and CLAUDE.md while every enforcement-relevant instruction survives, so that agents spend less context on boilerplate | must-have | 1 |
| Framework Context Bloat Audit | As the human running Planifest pipelines, I want a populated regression pack covering orchestrator routing, phase sequencing, hook enforcement, and gate behavior, so that the trims can be verified safe before they ship | must-have | 1 |

---

## Waves

Single wave — three tightly-coupled stories under one cohesive audit-then-trim pass, well under the 5-6 feature threshold for waving.

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| `planifest-framework` | component-pack | existing | Owns all touched artifacts: `skills/`, `templates/`, `standards/`, plus the repo root `CLAUDE.md` |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| n/a — no database, all artifacts are files | `planifest-framework` | n/a |

### Integration Points

None — no cross-component calls in this feature.

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown (instruction content); Bash (tests, scripts) |
| Runtime | none |
| Framework | none |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | existing `planifest-framework/tests/` suite (`run-tests.sh`) + newly-populated `tests/regression/` pack |
| IaC | none |
| Cloud | none |
| Compute | local developer toolchain |
| CI | existing `test-000xxxx-*.sh` pattern |
| Build target | local |

---

## Scope Boundaries

### In Scope
Strictly sequenced:
1. Regression-pack population: promote tests asserting orchestrator routing, phase sequencing, hook enforcement, and gate behavior from `planifest-framework/tests/` into `planifest-framework/tests/regression/` (prerequisite, pulled in from backlog `0000019`)
2. Run the populated regression pack once, before any audit or trim work, to record a baseline (pass/fail + self-correction counts)
3. Fresh-context `claude-opus-5` audit pass over every `SKILL.md`, every file under `planifest-framework/standards/`, every file under `planifest-framework/templates/`, and the root `CLAUDE.md`, producing a written findings report
4. Per-file trimming of redundant, restated, or model-implicit content identified by the audit; each trimmed file is reviewed by a second fresh-context reviewer against both guardrails (no enforcement-content loss, no ambiguity regression) before being committed; a file failing either guardrail retries with a failure-informed, more conservative reduction, up to 5 attempts, then reverts to original wording if still failing
5. Re-run the regression pack after all trims and compare against the baseline
6. Before/after line-count metrics and the baseline comparison recorded in the changelog

### Out of Scope
- Any file under `.claude/` — this is a synced copy installed by `setup.sh`'s skill-sync mechanism from `planifest-framework/`, never edited directly. It is refreshed separately by the human running setup/refresh after this feature ships.
- Structural decomposition of the orchestrator into a router + `references/` pattern (backlog `0000020`) — deferred
- Authoring a formal skill-scope principle ADR (backlog `0000024`) — deferred
- Conditional/minimal per-run artifact set (backlog `0000021`) — deferred, unrelated axis
- Any change to hook `.mjs` logic
- Any change to `planifest-framework/external-skills/` (third-party content)

### Deferred
- Orchestrator structural decomposition (backlog `0000020`) — blocked until general bloat is removed first, per human direction
- Skill-scope principle ADR (backlog `0000024`) — blocked until general bloat is removed first, per human direction

---

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Latency | not applicable | no runtime component |
| Availability | not applicable | no runtime component |
| Throughput | not applicable | no runtime component |
| Security | no new auth surface, no PII; `claude-opus-5` model override is project-scoped to this feature only | reviewed at P5 |
| Context efficiency | ≥20% line-count reduction across `planifest-framework/skills/*/SKILL.md` as a floor, no fixed ceiling — audit-driven per file. Zero loss of Hard-Limit/STOP-gate/enforcement-referenced content, and no increase in agent confusion/retries/escalations vs. the recorded regression-pack baseline | fresh-context reviewer diff against findings report + regression pack baseline-vs-after comparison + per-file changelog entry |

---

## Constraints and Assumptions

### Constraints
- Never edit anything under `.claude/` — it is generated, not authored
- Every Hard Limit, STOP gate, and enforcement-referenced instruction must survive the edit with its meaning intact
- No structural decomposition and no skill-scope ADR in this pass (see Deferred)
- The regression pack must be populated and run once to record a baseline before any audit or trim work begins — trimming may not start against an empty or partial baseline
- A trim that fails either guardrail (enforcement-content loss, or the after-trim regression pack showing new failures or more self-corrections than baseline) retries with a failure-informed, more conservative reduction, up to 5 attempts per file, then reverts to original wording — never left half-trimmed, never silently abandoned without a report to the human

### Assumptions
- The 29 existing test scripts in `planifest-framework/tests/` are sufficient raw material to promote from for the regression pack; no test-writing from scratch is required beyond promotion
- `claude-opus-5` is available to this session via the Agent tool's `model` parameter

---

## Scenario Paths

**Happy path:** The human on the loop sees a substantially leaner skill/template/standards corpus (≥20% line reduction floor across `skills/*/SKILL.md`, no fixed ceiling, audit-driven per file). Two guardrails cap how far that goes: zero loss of Hard-Limit/STOP-gate/enforcement-referenced content, and no increase in agent confusion, retries, or escalated "doom loops" versus before. The regression pack is populated and run first to record a baseline (pass/fail + self-correction counts) before any audit or trim work begins; audit and trim follow; the pack is re-run after trimming and compared against the baseline. Demonstrated by the regression pack passing in full and this pipeline run's own remaining P1-P9 phases (dogfooding the trimmed orchestrator and phase skills) showing no rise in self-corrections or escalations versus baseline.

> On the very first run the regression pack holds only one test, so it is filled out with the other candidate tests already in the suite before any baseline is recorded — otherwise the baseline would cover almost none of the framework's behavior. Once populated and a baseline is recorded, the run proceeds as any later run would: audit, then trim, then re-run and compare against the baseline.

> If a trim fails either guardrail (enforcement-content loss, or the after-trim regression pack showing new failures or more self-corrections than baseline), the specific failure details (which guardrail, which file, what broke) feed into the next attempt, which retries with a different, more conservative reduction and re-runs the regression pack. Up to 5 attempts per file. If none of the 5 pass both guardrails, the trim is abandoned and the file reverts to its original wording. The human always sees a report naming the file, which guardrail failed, how many attempts were made, and what each attempt tried.

> If a session is interrupted mid-audit or mid-trim, only the single file in progress at interruption is at risk; every already-finished file (recorded audit finding, or a trim that cleared both guardrails and was committed) is safe. Resume shows exactly which phase, file, and last artifact, continuing from there rather than restarting. A file is always either at its original wording or a reviewed committed trim, never half-trimmed, because commits only happen after both guardrails clear (or after reverting following 5 failed attempts). The regression-pack baseline, once recorded, is a completed independent artifact immune to later interruption.

---

## Acceptance Criteria

- [ ] Regression pack (`planifest-framework/tests/regression/`) is populated with tests covering orchestrator routing, phase sequencing, hook enforcement, and gate behavior, and is run once to record a baseline (pass/fail + self-correction counts) before any audit or trim work begins
- [ ] Fresh-context `claude-opus-5` subagent produces a written audit findings report covering every `SKILL.md`, every `standards/*.md`, every `templates/*.md`, and `CLAUDE.md`, produced only after the baseline is recorded
- [ ] Every Hard Limit, STOP gate, and enforcement-referenced instruction survives every applied trim, verified by a second fresh-context reviewer diffing before/after content against the findings report
- [ ] Total line count across `planifest-framework/skills/*/SKILL.md` drops by at least 20% from the 3,959-line baseline (floor, no fixed ceiling), with per-file before/after counts recorded in the changelog
- [ ] Any trim that fails either guardrail retries with a failure-informed reduction up to 5 attempts, then reverts to original wording if still failing, with a report to the human naming the file, guardrail, and attempts
- [ ] Regression pack is re-run after all trims and shows no new failures and no increase in self-corrections/escalations versus the recorded baseline
- [ ] `run-tests.sh` (full existing suite) passes after all edits
- [ ] `.claude/` is untouched by any commit in this feature

---

*This brief will be read by the orchestrator skill. See [planifest/skills/orchestrator/SKILL.md](../skills/orchestrator/SKILL.md)*
