---
title: "Scope - orchestrator-redundancy-removal"
summary: "Defines explicit boundaries of what is in scope and out of scope."
status: "draft"
version: "0.1.0"
---
# Scope - orchestrator-redundancy-removal

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Wave:** n/a (single wave)
**Version:** 0.22.0

## In Scope

- Removing content from `planifest-framework/skills/planifest-orchestrator/SKILL.md` that is already fully and correctly stated in a phase skill, workflow, standard, or template, replaced with a one-line pointer (req-002, Class 1: telemetry table, per-phase Input/Produces/Gate blocks, Fast Path detail, Scope Lock suggested-answer mechanics, reversal execute/assess mechanics, retrofit scan detail, Change Pipeline confirm questions, triple-stated phase-skill-load instruction)
- Relocating the Model Tier Decision Table and Parallelism Rules + Agent Dispatch Template out of the orchestrator into a new standards file, with `planifest-ship-agent` and `planifest-codegen-agent` re-pointed to it (req-003, Class 2)
- Trimming expository asides (rationale essays, coaching prose beyond what's operationally needed) from the orchestrator (req-004, Class 3)
- Updating every regression test that pins orchestrator content scheduled for removal or relocation, so it asserts the new canonical location instead (req-004)
- Running the regression pack before the first edit (req-001, baseline) and after all edits (req-005, comparison), per 0000021 ADR-002's baseline-gated trim process
- Updating `planifest-framework/component.yml`, `docs/component-registry.md`, and `docs/about.md` to reflect the change at ship

## Out of Scope

- Structural router decomposition of the orchestrator into `references/` (backlog 0000020) - this feature removes duplication only; it does not restructure the file into a router-plus-loaded-detail pattern
- Any change to phase-skill behaviour, hook `.mjs` logic, `setup.sh`/`setup.ps1`, or the pipeline's phase count, gates, or STOP rules
- All other open backlog entries (0000020, 0000021-backlog, 0000023 through 0000030) - none are pulled into this feature
- Changes under `.claude/` (synced copy, refreshed separately via setup.sh, confirmed gitignored)
- New enforcement mechanisms such as a word-count regression test (that belongs to backlog 0000020's decomposition work, not this de-duplication pass)
- The Scope Lock draft-flow inversion (backlog 0000029) and the marker-commit-at-creation mandate (backlog 0000030) - both filed as backlog during this feature's P0 but neither is implemented here

## Deferred

- Nothing deferred. Every acceptance criterion in the confirmed design is addressed by req-001 through req-005; nothing was pushed out of this feature's own scope for later resolution within the feature itself.
