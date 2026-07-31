# Changelog — 0000018-telemetry-emission-consistency — 31 Jul 2026

**Feature:** Telemetry Emission Consistency
**Pipeline run:** P0–P6 completed, continuous run authorized at design confirmation; no phases skipped
**Version:** 0.17.0 → 0.18.0
**PR:** TBD — filled in at P9

## What Was Built

Zero telemetry events were emitted during the entire 0000017 pipeline run despite telemetry being "enabled" — emission was soft-gated in agent instructions ("skip silently if unavailable") with zero enforcement, and installer wiring had a latent bug. This feature closes both gaps and adds a self-audit finding discovered during its own P0:

- **Unified telemetry gating signal** — `setup.sh`/`setup.ps1`'s `install_telemetry_hooks`/`Install-TelemetryHooks` no longer requires `--context-mode-mcp` in addition to `--structured-telemetry-mcp`; the latter alone is sufficient, closing the exact AND-condition gap that caused 0000017's telemetry loss.
- **Durable failure markers** — `emit-phase-start.mjs`, `emit-phase-end.mjs`, and `context-pressure.mjs` now write a best-effort JSON marker to `plan/.telemetry-failures/<hook>--<error_type>--<slug>.json` on emission failure, instead of swallowing the error with no trace. ADR-005's exit-zero/never-block guarantee (0000003) is unchanged.
- **Interactive failure recovery** — `planifest-orchestrator` checks for failure markers at the start of every phase (P0–P9) and surfaces a block-or-proceed question to the human once per distinct root cause per run, recording the answer as a `Telemetry` field in `build-log.md`. Agent-driven `emit_event` failures ask the same question inline, in the same turn.
- **Emission is mandatory when enabled** — all 8 phase skills' Telemetry sections rewritten to remove the old "skip silently if unavailable" framing.
- **Build-log telemetry record** — every phase block now carries a `Telemetry` field (`emitted` / `failed-with-recorded-choice` / `confirmed-disabled`); no phase can complete with the field blank.
- **discovery.md elevated to Hard Limit status** (self-audit finding, picked up mid-scope with human approval) — a missing or incomplete `discovery.md` before P0 coaching begins is now a pipeline error, matching `build-log.md`'s proven Hard Limit 8 enforcement pattern, closing the same "numbered step with no enforcement teeth" failure class this feature exists to fix for telemetry.

`query_telemetry`/backend changes were explicitly kept out of scope — confirmed fully functional this session, owned by the sibling `structured-telemetry-mcp` repo. No migration mechanism was built for legacy single-signal installs (human-confirmed: no practical legacy install base exists).

## Artifacts Produced

- `plan/current/`: design (3 user stories, 9 ACs), 7 requirement files, execution-plan, scope, risk-register (5 risks + 2 assumptions), domain-glossary (9 terms), operational-model, slo-definitions, cost-model, 3 ADRs, security-report (risk Low, 1 finding fixed inline), recommendations, build-log
- `planifest-framework/`: `setup.sh`/`setup.ps1` gating fix, 3 telemetry hooks gain `recordTelemetryFailure()`, `planifest-orchestrator/SKILL.md` marker-check-and-prompt logic + discovery.md Hard Limit 11 + every-phase Telemetry field requirement, 7 other phase skills' Telemetry sections rewritten, `telemetry-standards.md` v2.0.0, `build-log.template.md` Telemetry field, 6 new test suites (req-001/002/003/004/005/007) + 1 updated shared suite (req-006/test-skill-telemetry.sh)
- `.gitignore`: `plan/.telemetry-failures/` added (security finding fix)
- Living docs: component-registry (v0.18.0 summary), decisions-index (+3 ADRs), architecture-overview (+Telemetry section, +3 ADR references)

## Decisions

- ADR-001 (this feature): unify telemetry gating by removing the `--context-mode-mcp` coupling
- ADR-002 (this feature): telemetry failure detection and interactive recovery
- ADR-003 (this feature): discovery.md elevated to Hard Limit status

## Skipped Phases

None.
