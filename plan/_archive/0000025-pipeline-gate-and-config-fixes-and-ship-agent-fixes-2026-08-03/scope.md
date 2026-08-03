---
title: "Scope - pipeline-gate-and-config-fixes-and-ship-agent-fixes"
summary: "Defines explicit boundaries of what is in scope and out of scope."
status: "draft"
version: "0.1.0"
---
# Scope - pipeline-gate-and-config-fixes-and-ship-agent-fixes

**Skill:** [spec-agent](../../.claude/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Wave:** 1 of 1 (single wave — all seven stories are small, same-component fixes with no cross-dependencies)
**Version:** 0.1.0

> All three sections must be present. If "Deferred" is empty, state "Nothing deferred."

## In Scope

- `planifest-ship-agent/SKILL.md`: remove the hardcoded AI-attribution footer from the P9 PR description template, for both the `gh pr create` output path and the human-push description output path; default is off, with a toggle designed in case adopters want it back (US-001)
- `planifest-ship-agent/SKILL.md`: fix P7 Step 7's archive commit so its `git add` explicitly names `plan/current/`, rather than relying on git's rename-detection heuristic to pick up the copy-then-delete (US-002)
- Orchestrator's Parallelism Rules / Agent Dispatch Template, and relevant phase skills: extend the "MUST parallelise independent writes" pattern already used at P1/P3 to other phases with independent, non-cross-referencing writes — at minimum P4 (test files) and P6 (living-doc edits) (US-003)
- Setup scripts (`setup.sh`/`setup.ps1` and tool adapters): write active setup flags/backend-url to `planifest-overrides/setup-config/{tool}.md` (or equivalent), in addition to or replacing the existing gitignored `.planifest-setup-flags` marker, one file per AI tool (US-004)
- `recommendations.md` template/agent behavior: route Deferred Items and Tech Debt table entries into `plan/backlog/{id}-{slug}/`, tagged with their source feature, instead of or alongside the existing recommendations.md tables (US-005)
- `planifest-docs-agent/SKILL.md` P6 Gate B: check `plan/.run-mode`/`continuous_run` before stopping for confirmation; audit other phase skills (spec-agent, adr-agent, codegen-agent, and others) for the same internal-gate pattern and fix any found (US-006)
- `planifest-orchestrator/SKILL.md` Scope Lock Challenge protocol, plus `0000017-ADR-003`: change the default to always-draft-and-batch-present — all four scenario-path answers drafted up front via `planifest-scope-lock-agent`, dispatched in parallel, human does one batch accept/edit/reject pass instead of four sequential opt-in round-trips; a new ADR records the change, scoped narrowly so it supersedes/amends `0000017-ADR-003` without reading as a framework-wide reversal of `0000014-ADR-008`'s one-question-at-a-time convention (US-007)

## Out of Scope

- Any change to `structured-telemetry-mcp` or other external MCP servers
- New capability skills or new components
- The 12 other backlog items reviewed at P0 and left for future runs (0000020, 0000021, 0000022, 0000023, 0000024, 0000025 backlog items, 0000026, 0000034, 0000035)
- Retroactively rewriting already-archived features' `recommendations.md` files to backfill the backlog-unification pattern — 0000038's scope is the mechanism going forward, not a data migration

## Deferred

- Whether the PR-footer toggle mechanism (US-001) should default to a `planifest-overrides/instructions/`-gated file or a simpler hardcoded removal — left for the P1 spec-agent / P2 ADR to decide with the human, per the backlog entry's own note that this is "a design decision for whoever picks this up." **Blocked until resolved:** the exact shape of US-001's functional requirement and its P2 ADR cannot be finalized — whether the toggle needs a data contract in `planifest-overrides/instructions/` or is a one-line template edit — so this decision must be made before requirements drafting for US-001 completes.
- Nothing else deferred — confirmed via the Scope Lock Challenge at P0.
