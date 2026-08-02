---
title: "Scope - Framework Pipeline Fixes"
summary: "Defines explicit boundaries of what is in scope and out of scope."
status: "active"
version: "0.1.0"
---
# Scope - Framework Pipeline Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Wave:** 1 (single wave)
**Version:** 0.23.0

## In Scope

- Restore the `continuous_run` exception for P1 (Requirements), P2 (ADRs), and P3 (Codegen) STOP rules in `planifest-framework/skills/planifest-orchestrator/SKILL.md`'s Phase Invocation Table, matching how P4-P6 already work. Record via ADR, including the root-cause finding (commit `42ae808`, feature 0000021).
- Commit `plan/.orchestrator-active` and `plan/.orchestrator-ack` at the point they are written in Phase 0 (creation-side marker commit).
- Stage all three session markers in `planifest-ship-agent`'s P7 "Commit archive" `git add`, so their deletion lands atomically with the archive commit (deletion-side marker commit).
- Add a P9 pre-flight check in `planifest-ship-agent` that warns if any of the three markers are still tracked in git before the PR is raised (durable backstop).
- Fix `TOOL_HOOK_ADAPTER_DEST` in `planifest-framework/setup/copilot.sh` to a project-local path (`.github/hooks/adapters/copilot.mjs`), matching every other Tier-1 tool; update the `.github/hooks/planifest.json` heredoc's two `command` fields to match.
- Add the equivalent Tier-1 keys (`HookAdapterSrc`, `HookAdapterDest`, `HooksInstallDir`) to `copilot.ps1`'s config hashtable, plus a `SettingsFile`-presence guard fix in `setup.ps1`'s dispatcher so it doesn't incorrectly call `Install-Tier1HookRegistration` for Copilot (found during requirements investigation).
- Add a `product_id` field, derived via `git rev-parse --show-toplevel` with a raw-`cwd` fallback, to the three telemetry hook scripts (`emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs`) and to the canonical Event Envelope template in `telemetry-standards.md`.
- Regression test coverage for the copilot setup fix (bash, live-verified) and the telemetry `product_id` derivation (both git-repo and non-git-repo cwd cases).

## Out of Scope

- The other 7 open backlog entries (0000020, 0000021, 0000022, 0000023, 0000024, 0000025, 0000026, 0000029) — left untouched per the P0 backlog-pickup decision.
- Any general `setup.sh`/`setup.ps1` refactor beyond the copilot DEST fix and the dispatcher-guard gap named above.
- Hook wiring for any tool other than Copilot.
- Backfilling `product_id` on historical telemetry rows — permanently `"unknown"` per source ADR-017.
- Any change to `structured-telemetry-mcp`'s schema, DB layer, or UI.
- Toggling `p0_completeness`, `design_critic`, `cross_model_review`, or `reversal_protocol` — all remain at their existing off defaults for this run.

## Deferred

- Live `pwsh` verification of the `copilot.ps1` fix (including the dispatcher-guard change) — no PowerShell runtime available in this environment. Verified statically only (grep-based checks in the new regression test). Blocked until a Windows/`pwsh`-capable environment is available to run `setup.ps1 copilot` end to end.
