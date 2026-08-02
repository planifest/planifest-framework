---
title: "Feature Brief - Framework Pipeline Fixes"
summary: "Batch of five small, independently-filed correctness fixes to the Planifest framework's own pipeline tooling: a continuous_run regression, a marker commit-lifecycle gap (both ends), a setup.sh crash, and an incomplete telemetry field."
status: "approved"
version: "0.1.0"
---
# Feature Brief - Framework Pipeline Fixes

**Feature ID:** 0000023-framework-pipeline-fixes

## Business Goal

Five small, independently-discovered defects have accumulated in the framework's own pipeline tooling since 0000020: a continuous-run regression that silently reintroduces three forced stops, a session-marker commit-lifecycle gap at both creation and deletion, a setup script that crashes on every invocation for one tool target, and a telemetry envelope field that ships unpopulated. None require a design decision beyond what's already resolved in this brief. Fixing them together restores trust in continuous_run and resume mechanics before the next feature pipeline run relies on them.

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| Restore continuous_run for P1-P3 | As a human on the loop running continuous mode, I want P1 (Spec), P2 (ADRs), and P3 (Codegen) to skip the confirmation stop the same way P4-P6 already do, so that continuous_run behaves as previously verified (0000019, 0000020) instead of forcing three unwanted interruptions. | must-have | 1 |
| Marker commit-lifecycle (creation + deletion) | As a human on the loop, I want `plan/.orchestrator-active`, `plan/.orchestrator-ack`, and `plan/.run-mode` committed the moment they're written at P0 and reliably removed from the commit that archives at P7, so that a lost working tree or a rushed PR never strands stale sentinel state on `main`. | must-have | 1 |
| Fix setup.sh/setup.ps1 copilot crash | As a human running `setup.sh copilot` (or `setup.sh all`), I want the command to exit 0 instead of aborting on a self-copy `cp` failure, so that Copilot tool setup actually works. | must-have | 1 |
| Emit product_id in telemetry | As anyone consuming telemetry data across multiple projects sharing one backend — a human via the log-viewer UI, an API caller, or an agent querying via MCP tools — I want every event the framework emits to carry `product_id`, so that events attribute to the right repo regardless of how they're consumed, instead of showing "unknown". | must-have | 1 |

## Waves

Single wave — all four features are small, touch the same component (`planifest-framework`), and have no dependency ordering between them.

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| `planifest-framework` | component-pack | existing | Core standards, skills, hooks, and setup scripts. All five fixes land here — none touch `setup-hook-integration` or `context-mode-hooks`. |

### Data Ownership

No new data stores. `plan/.orchestrator-active`, `plan/.orchestrator-ack`, `plan/.run-mode` are session sentinel files, not component-owned data (already covered by `gate-write.mjs`'s always-permitted-files list).

### Integration Points

None new. `planifest-framework`'s telemetry hooks POST to the same `structured-telemetry-mcp` backend already in use; only the envelope gains one optional field.

## Stack

| Concern | Decision |
|---------|----------|
| Language | Bash (setup scripts), Markdown/prose (SKILL.md, ADRs), Node.js/JavaScript (`.mjs` hook scripts) |
| Runtime | Node (hooks), Bash (setup) |
| Framework | none |
| Frontend | none |
| Database | none |
| ORM | none |
| Testing | existing Bash regression suite (`planifest-framework/tests/regression/*.sh`) |
| IaC | none |
| Cloud | none |
| Compute | none |
| CI | GitHub Actions (existing) |
| Build target | local |

## Scope Boundaries

### In Scope
- Restore `continuous_run` exception wording for P1, P2, P3 in `planifest-framework/skills/planifest-orchestrator/SKILL.md`'s Phase Invocation Table, matching the verified pre-0000021 semantics (see agreed wording, build-log P0 exchange). Record via ADR, including the root-cause finding that this was an unintended regression introduced in commit `42ae808` (feature 0000021), not a pre-existing or deliberate design choice.
- `planifest-ship-agent`: make marker deletion (`plan/.orchestrator-active`, `plan/.orchestrator-ack`, `plan/.run-mode`) atomic with the P7 archive commit, AND add a P9 pre-flight check that fails/warns if any of the three are still tracked and non-empty before the PR is raised.
- `planifest-orchestrator/SKILL.md` Phase 0 Start Actions steps 1 and 5: add explicit "commit this marker now" instructions for `.orchestrator-active` and `.orchestrator-ack`, matching the existing instruction already present for `.run-mode`.
- `planifest-framework/setup/copilot.sh` and `copilot.ps1`: fix the `TOOL_HOOK_ADAPTER_DEST` self-copy bug by pointing it at a project-local destination (`.github/hooks/adapters/copilot.mjs`), consistent with every other Tier-1 tool adapter; update the `.github/hooks/planifest.json` heredoc's `command` fields to reference the copied destination instead of reaching back into `planifest-framework/`; add the missing `HookAdapterSrc`/`HookAdapterDest`/`HookInstallDir` keys to `copilot.ps1`'s config hashtable so PowerShell installs Tier-1 hooks for Copilot at all (currently silently skipped, no crash but no-op); add a regression test asserting `setup.sh copilot` exits 0 on a fresh workspace.
- Three telemetry hook scripts (`emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs`) under `planifest-framework/hooks/telemetry/`: add a `getProductId(cwd)` helper (git root via `git rev-parse --show-toplevel`, fallback to raw `cwd`, silent-on-error) and include `product_id` in each emitted event object.
- `planifest-framework/standards/telemetry-standards.md`: add `product_id` to the canonical Event Envelope template; audit the skill files matched by `grep -rl emit_event planifest-framework/skills/` for any hardcoded envelope copy missing the field.
- Regression test coverage for both the telemetry `product_id` derivation (git-repo and non-git-repo cwd cases) and the copilot setup fix.
- Correct backlog entry 0000031's "pre-existing behaviour, not introduced by feature 0000022" claim to name 0000021/commit `42ae808` as the actual origin, when folding it into this feature's requirements.

### Out of Scope
- The other 7 open backlog entries (0000020, 0000021, 0000022, 0000023, 0000024, 0000025, 0000026, 0000029) — left untouched, per P0 backlog-pickup confirmation.
- Any general `setup.sh`/`setup.ps1` refactor beyond the copilot DEST fix and the PowerShell Tier-1 parity gap named above.
- Hook wiring for any tool other than Copilot.
- Backfilling `product_id` on historical telemetry rows (explicitly out of scope per source ADR-017 — they remain `"unknown"` permanently).
- Any change to `structured-telemetry-mcp`'s schema, DB layer, or UI (already shipped correctly in that product's own 0000015).
- A `p0_completeness` loop, `design_critic`, `cross_model_review`, or `reversal_protocol` toggle change — all stay at their existing defaults (off) for this run.

### Deferred
- Live `pwsh` verification of the `copilot.ps1` fix — this environment has no PowerShell available (consistent with the pre-existing note in `setup-hook-integration`'s component.yml quirks list, Q-006). Verified statically only; blocked until a Windows/pwsh environment is available.

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Telemetry emission latency | No added latency beyond existing 3s fetch-abort budget | `git rev-parse --show-toplevel` is a local, sub-millisecond, synchronous call — no network/async involved |
| Setup script exit code | `setup.sh copilot` and `setup.sh all` exit 0 on a fresh workspace | New regression test asserts exit code |
| Silent-on-error | `getProductId` must never throw past its own try/catch; a missing `git` binary or non-repo cwd falls back to raw `cwd`, never blocks emission | Matches existing ADR-005 fail-open pattern; covered by regression test |

## Constraints and Assumptions

### Constraints
- No schema change needed on either the framework or `structured-telemetry-mcp` side for `product_id` — the field already exists as optional in `schemas/telemetry-event.schema.json`.
- `.github/hooks/planifest.json`'s command paths must stay consistent with wherever `TOOL_HOOK_ADAPTER_DEST` copies the adapter to — both must change together.

### Assumptions
- `planifest-framework/skills/` is the canonical source; `.claude/skills/` is a synced build artifact (confirmed stale mid-session — the copy loaded at skill-invocation time predated 0000022's table consolidation). This feature edits the canonical source only; a skill-sync/setup re-run is expected to refresh `.claude/skills/` afterward, which is outside this feature's scope to trigger.
- No live `pwsh` runtime available in this environment (confirmed no `pwsh`/PowerShell present); `copilot.ps1` changes are verified by static review and by structural parity with the existing `.sh`/`.ps1` pairs, not by live execution.

## Scenario Paths

**Happy path:** Each of the five fixes lands as its own requirement (P1), gets validated (P4) and security-reviewed (P5) together as one small batch, and ships as one PR touching only `planifest-framework/` files, with an ADR recording the continuous_run restoration and its root cause.

**First-run path:** Not applicable in the traditional sense (no new data/state) — the closest analogue is a *first continuous_run pipeline execution after this fix lands*: P1, P2, P3 should skip their stops exactly as P4-P6 already do, verified by this very pipeline run once `continuous_run` is confirmed at P0.

**Error / sad path:** If the `getProductId` git call fails (no git binary, detached worktree, permission error), the hook must fall back to raw `cwd` silently and still emit the event — never block or crash telemetry emission. If `setup.sh copilot` still fails after the fix (e.g. a GNU-vs-BSD `cp` difference not yet observed), the new regression test catches it before ship rather than another human discovering it live.

**Cross-session continuity:** This feature's own session markers (`.orchestrator-active`, `.orchestrator-ack`, `.run-mode`) are themselves committed at creation per the fix being implemented (0000030) — this pipeline run dogfoods its own deliverable. If interrupted mid-run, `plan/current/pause.md` and the build log carry full resume state as normal.

## Acceptance Criteria

- [ ] P1-P3 STOP rules in the Phase Invocation Table honor `continuous_run: true` per the agreed wording; ADR records the fix and root cause (commit `42ae808`, feature 0000021)
- [ ] `planifest-ship-agent` P7 marker deletion is atomic with the archive commit; a P9 pre-flight check blocks/warns if markers are still tracked and non-empty
- [ ] Phase 0 Start Actions steps 1 and 5 instruct committing `.orchestrator-active` and `.orchestrator-ack` at creation
- [ ] `setup.sh copilot` and `setup.ps1 copilot` exit 0 on a fresh workspace; regression test added (bash live-verified, ps1 statically verified)
- [ ] `product_id` appears in every event emitted by the three telemetry hooks and in the canonical envelope template; regression test covers git-repo and non-git-repo cwd cases
- [ ] All five backlog folders (0000027, 0000028, 0000030, 0000031, 0000032) deleted, folded into this feature's requirements
