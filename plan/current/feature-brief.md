---
title: "Feature Brief - backlog-batch-governance-tooling-fixes"
summary: "The business case, scope, and product requirements for the feature."
status: "approved"
version: "0.1.0"
---
# Feature Brief - backlog-batch-governance-tooling-fixes

**Feature ID:** 0000027-backlog-batch-governance-tooling-fixes

> Sourced from 8 confirmed `plan/backlog/` entries (folded in at P0 pickup, see `plan/current/build-log.md`), not authored fresh by a human for this run. Each entry's own Problem/Suggested Action stands in for initial requirements discussion.

## Business Goal

Close eight governance and tooling gaps surfaced by prior pipeline runs' self-review and live operation: two setup-script bugs that can abort a clean install (`cline.sh` path collision, unwired telemetry hooks), two orchestrator-conduct gaps that risk silently losing telemetry compliance, one process fix so subagents file discoveries through the framework's own backlog protocol instead of a host-tool side channel, one historical-backlog backfill, one new P0 flow distinguishing a framework dependency update from an arbitrary code push, and one governance ADR plus one artifact-minimization fix reducing documentation theatre. All eight already carry a confirmed problem statement and suggested action from prior runs.

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| 0000043 - wire phase_start/phase_end hooks | As the human on the loop, I want phase_start/phase_end telemetry hooks wired into setup.sh/setup.ps1 alongside context-pressure.mjs, so that all hooks gated by the unified telemetry signal are actually registered and no event type silently goes unemitted. | must-have | 1 |
| 0000034 - fix cline.sh path collision | As a downstream adopter running setup.sh for Cline, I want the boot-file and skills-dir paths in cline.sh/cline.ps1 to stop colliding, so that `setup.sh cline` and `setup.sh all` complete successfully on a fresh workspace. | must-have | 1 |
| 0000035 - subagents file to backlog, not spawn_task | As a dispatched phase-agent subagent, I want explicit instruction to file an out-of-scope discovery to `plan/backlog/` directly, so that discovered bugs enter the Planifest backlog-pickup protocol instead of bypassing it via a host-tool mechanism. | should-have | 1 |
| 0000044 - deterministic telemetry compliance backstop | As the orchestrator, I want a deterministic backstop that checks `plan/.telemetry-failures/` at every phase boundary and verifies agent-driven `emit_event` calls actually happened, so telemetry compliance doesn't depend solely on prose instruction and memory. | must-have | 1 |
| 0000045 - backfill historical recommendations into backlog | As the human on the loop, I want deferred items and tech debt from `recommendations.md` in features archived before 0000025 backfilled into `plan/backlog/`, so a future P0 backlog-pickup pass that reads only `plan/backlog/` surfaces them too. | could-have | 1 |
| 0000046 - explicit P0 framework-dependency-update flow | As the human on the loop, I want P0 to explicitly distinguish a `planifest-framework/` dependency update from an arbitrary code push, requiring my confirmation of both the update and its provenance, so framework upgrades are trusted like any other declared dependency bump rather than treated with blanket suspicion. | should-have | 1 |
| 0000024 - record skill-scope principle ADR | As a framework maintainer, I want an ADR recording the "does this skill earn its place" governance test with the four TDD-loop skills as worked examples, so future skill additions/removals are judged against a documented standard rather than a duplication argument alone. | could-have | 1 |
| 0000021 - define minimal artifact set | As a framework maintainer, I want a minimal default Phase 1 artifact set with explicit trigger conditions for the rest (cost model, SLOs, operational model), reflected consistently in `feature-pipeline.md` and `planifest-spec-agent`, so trivial features stop producing documentation theatre that causes reviewers to disengage. | should-have | 1 |

## Waves

Single wave — all 8 features ship together in this run (confirmed at P0: batch is small, well-specified, and touches only `planifest-framework` / `setup-hook-integration` with no cross-component conflicts; precedent: feature `0000025` shipped 7 similarly-scoped items in one run). P3 applies subagent decomposition per-requirement rather than separate pipeline runs.

## Target Architecture

The agent implements within these constraints - it does not choose the architecture.

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Orchestrator skill, phase skills, ADRs, workflows (`feature-pipeline.md`), hook sources (`emit-phase-start.mjs`/`emit-phase-end.mjs`), migrations, `planifest-spec-agent` |
| setup-hook-integration | component-pack | existing | `setup.sh`/`setup.ps1`, tool adapters (`cline.sh`/`cline.ps1`), hook wiring into target-tool configs |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| N/A | N/A | No runtime data stores in play — all artifacts are the framework's own files (skills, hooks, docs, ADRs, backlog/build-log entries). |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| setup-hook-integration (`setup.sh`/`.ps1`) | planifest-framework (`hooks/telemetry/*.mjs`) | filesystem copy + tool hook-config registration | Existing contract, unchanged — this feature fixes wiring gaps, not the contract itself. |

## Stack

| Concern | Decision |
|---------|----------|
| Language | Bash, Node.js (ESM), Markdown |
| Runtime | Node (`.mjs` hooks), POSIX shell (setup scripts) |
| Framework | none |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | bash regression scripts (`planifest-framework/tests/test-*.sh` convention) |
| IaC | none |
| Cloud | none |
| Compute | none |
| CI | GitHub Actions (`.github/workflows/planifest.yml`) |
| Build target | local |

## Scope Boundaries

### In Scope
- Implement all 8 backlog items above (0000043, 0000034, 0000035, 0000044, 0000045, 0000046, 0000024, 0000021) as this feature's requirements.

### Out of Scope
- Backlog entries `0000040`/`0000041` referenced from `0000046`'s problem statement — not present in this repo's `plan/backlog/`; external to this run.
- Retroactively rewriting already-archived features' `recommendations.md` files beyond the one-time backfill pass in `0000045` (per `0000045`'s own stated exclusion).
- Any remaining `plan/backlog/` entries not in the confirmed batch (`0000020`, `0000022`, `0000023`, `0000025`, `0000026`, `0000042`) — left untouched, available for a future pickup.

### Deferred
- Nothing newly deferred at brief level. Each item's own "Why Deferred" is now resolved by inclusion in this batch.

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Setup reliability | `setup.sh cline` and `setup.sh all` exit 0 on a fresh workspace | Regression test, same pattern as `test-0000023-req-003-copilot-setup-self-copy.sh` |
| Telemetry completeness | `phase_start`/`phase_end` hooks registered and firing for 100% of phase transitions when the unified telemetry signal is active | Hook-registration presence check + verification test |

## Constraints and Assumptions

### Constraints
- No new stack, service, or infra — all 8 items modify existing framework/setup-tooling files in place.
- Data ownership boundaries in `discovery.md` (no shared writes between `planifest-framework` and `setup-hook-integration`) must hold.

### Assumptions
- `0000046`'s and `0000044`'s exact mechanisms are explicitly undecided in their backlog entries — P2 ADRs will resolve the open design questions (new agent vs. extend `planifest-migrator`; hook vs. lint-check backstop, or both).
- Ops model / cost model / SLOs: N/A for this feature — zero deployed runtime footprint, no new service or infra (judgment call per `0000021`'s own not-yet-shipped minimal-artifact-set rule; confirmed with the human on the loop at P0).
- Security: no auth strategy applies (no runtime auth surface); data classification is none (no user/PII data — only the framework's own scripts/docs).

## Scenario Paths

> Left blank intentionally — derived by the Scope Lock Challenge (`planifest-scope-lock-agent`, dispatched in parallel) from the 8 user stories and NFRs above, since this feature has no single end-user-facing flow.

**Happy path:**

> {{happy-path}}

**First-run path:**

> {{first-run-path}}

**Error / sad path:**

> {{error-sad-path}}

**Cross-session continuity:**

> {{cross-session-continuity}}

## Acceptance Criteria

- [ ] `setup.sh`/`setup.ps1` register `emit-phase-start.mjs` and `emit-phase-end.mjs` alongside `context-pressure.mjs` under the unified telemetry signal (0000043)
- [ ] `cline.sh`/`cline.ps1` no longer collide on boot-file/skills-dir paths; `setup.sh cline` and `setup.sh all` exit 0 on a fresh workspace with a regression test proving it (0000034)
- [ ] Orchestrator dispatch guidance (template and/or per-phase-skill) instructs subagents to file out-of-scope discoveries to `plan/backlog/` per `templates/backlog-entry.template.md`, not via a host-tool mechanism (0000035)
- [ ] A deterministic mechanism (hook and/or gate check) verifies `plan/.telemetry-failures/` is checked at every phase boundary and that agent-driven `emit_event` calls specified per phase skill actually occurred (0000044)
- [ ] Every pre-0000025 archived feature's `recommendations.md` Deferred Items/Tech Debt rows are filed as tagged `plan/backlog/{id}-{slug}/entry.md` with correct `Source feature`/`Source phase`/`Deferral source` (0000045)
- [ ] P0 has an explicit step that detects a `planifest-framework/` dependency update, requires human confirmation of both the update and its provenance, and the resulting mechanism is documented as this repo's actual Framework Update Policy (0000046)
- [ ] An ADR records the skill-scope-principle test ("does this skill earn its place") with the four TDD-loop skills as worked examples, including the marginal verdict on `planifest-refactor` (0000024)
- [ ] `feature-pipeline.md` and `planifest-spec-agent` agree on a named minimal default artifact set with explicit trigger conditions for cost model / SLOs / operational model, and the README states the default artifact count for a typical feature (0000021)
