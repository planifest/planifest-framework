# Changelog - 0000020-setup-refresh-skill - 01 Aug 2026

**Feature:** Setup Refresh Skill
**Pipeline run:** P0-P9 complete, no phases skipped
**PR:** https://github.com/planifest/planifest-framework/pull/45

## What Was Built

Refreshing a Planifest install's generated artifacts previously required manually reconstructing the original `setup.sh`/`setup.ps1` invocation (tool and every flag) by reading installed hook wiring and marker files by hand. This feature adds `planifest-refresh-setup`, a standalone skill that:

- Detects the target tool (named by the human on the loop, or asked for if more than one install is present)
- Reconstructs the setup flags currently in effect from a new flags-used marker file (`.planifest-setup-flags`, written by `setup.sh`/`setup.ps1` on every successful install) or, if absent, from installed hook wiring, reporting a confidence level per flag
- Always requires explicit human confirmation before any destructive action, regardless of confidence
- Deletes only `CLAUDE.md`/`AGENTS.md` via a new hardcoded script (`refresh-delete-boot-files.sh`/`.ps1`), never any other file
- Re-invokes `setup.sh`/`setup.ps1` with the confirmed flags, with explicit failure handling (stop, investigate cause, print the attempted command, no automatic retry) and cross-session recovery if a refresh is interrupted mid-run

## Artifacts Produced

- `plan/current/feature-brief.md`, `discovery.md`, `design.md`, `execution-plan.md`, `scope.md`, `risk-register.md`, `domain-glossary.md`, `operational-model.md`, `slo-definitions.md`, `cost-model.md`, `security-report.md`, `recommendations.md`, `build-log.md`
- `plan/current/requirements/req-001` through `req-010`
- `plan/current/adr/ADR-001` through `ADR-005`
- `planifest-framework/skills/planifest-refresh-setup/SKILL.md` (new skill)
- `planifest-framework/scripts/refresh-delete-boot-files.sh` and `.ps1` (new, added during P5 security hardening)
- `planifest-framework/setup.sh` and `setup.ps1` (modified: flags-used marker write)
- `planifest-framework/tests/test-0000020-req-008-install-time-marker-write.sh` (21 assertions)
- `planifest-framework/tests/test-0000020-req-001-010-refresh-setup-skill.sh` (34 assertions)
- `planifest-framework/tests/test-0000020-req-004-boot-file-deletion-script.sh` (13 assertions)
- `src/setup-hook-integration/docs/data-contract.md` (new: marker file schema)
- `src/setup-hook-integration/component.yml`, `docs/purpose.md`, `docs/interface-contract.md`, `docs/scope.md`, `docs/risk.md`, `docs/quirks.md`, `docs/test-coverage.md` (updated)
- `planifest-framework/component.yml` (updated to v0.20.0)
- `docs/component-registry.md`, `docs/dependency-graph.md`, `docs/architecture-overview.md`, `docs/decisions-index.md` (updated)
- `.gitignore` (fixed: `.planifest-setup-flags` gitignore gap, P5 finding)
- `plan/backlog/0000026-ai-writing-tells-style-guard/entry.md` and `plan/backlog/0000027-setup-sh-copilot-broken-self-copy/entry.md` (filed during this run)

## Decisions

- ADR-001: Hardcoded, non-extensible deletion allowlist, extracted into a dedicated script during P5 after a security review found the original SKILL.md-prose-only rule had no deterministic backstop
- ADR-002: Single marker file (`.planifest-setup-flags`) serves as both the install-time flag record and the refresh skill's retry/recovery cache, not two separate files
- ADR-003: Mandatory human confirmation gate before any refresh action, in every run, including all-high-confidence runs
- ADR-004: Tool selection is explicit input to the refresh skill, never silently auto-resolved when multiple tools are installed
- ADR-005: No automatic retry on a failed setup re-invocation; retry is always a fresh, human-initiated run

## Skipped Phases

None.
