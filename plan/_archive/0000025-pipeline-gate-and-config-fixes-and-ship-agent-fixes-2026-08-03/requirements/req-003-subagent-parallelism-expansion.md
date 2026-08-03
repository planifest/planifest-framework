---
title: "Requirement: req-003 - subagent parallelism expansion"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-003 - subagent parallelism expansion

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source:** US-003
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want independent, non-cross-referencing writes across all pipeline phases (not just P1/P3) dispatched in parallel subagents, so that pipeline wall-clock time drops without changing output quality.

## Functional Requirements
- `planifest-framework/standards/agent-dispatch-standards.md`'s "MUST parallelise" table MUST gain two named patterns matching the backlog entry's own worked example (`plan/backlog/0000036-expand-subagent-parallelism-for-speed/entry.md`): (a) new test files written to close a coverage gap, each testing independent, non-cross-referencing sections, and (b) independent living-doc edits with no shared content between them.
- `planifest-validate-agent/SKILL.md`'s Parallelism Directive (P4) currently covers only CI-check execution order (lint/typecheck/test/build). It MUST be extended to also cover authoring multiple new test files to close a coverage gap: when 2+ new test files are independent and non-cross-referencing, they MUST be dispatched in a single parallel batch rather than written one after another in-band.
- `planifest-docs-agent/SKILL.md`'s Parallelism Directive (P6) currently covers per-component docs, drift checks, and recommendations+iteration-log, but does not name the Mandatory Living Docs table (`docs/component-registry.md`, `docs/dependency-graph.md`, `docs/architecture-overview.md`, `docs/decisions-index.md`, `docs/api-index.md`) as parallelisable. It MUST gain an explicit MUST-parallelise entry: when 2+ of these living docs require updates in the same run and the edits do not read each other's new content, dispatch them in a single parallel batch rather than editing them serially.
- Both updated Parallelism Directive tables MUST retain (not remove) their existing "Cannot parallelise" entries and existing MUST-parallelise rows — this requirement adds coverage, it does not narrow or replace what already exists.
- The extension MUST NOT change the phases' existing hard sequencing (e.g. P4's lint/typecheck-before-test-before-build order, P6's dependency-graph-after-component-files order) — only writes that are genuinely independent and non-cross-referencing gain parallel-dispatch guidance.
- No change to output content is permitted — the requirement governs dispatch mechanics (parallel vs. serial), not what gets written.

## Acceptance Criteria
- [ ] `planifest-framework/standards/agent-dispatch-standards.md`'s MUST-parallelise table includes a row for independent new-test-file authoring (coverage-gap closure) and a row for independent living-doc edits, each citing the pattern (not just P1/P3-specific examples).
- [ ] `planifest-validate-agent/SKILL.md`'s Parallelism Directive table includes a MUST-parallelise row for "2+ independent new test files closing a coverage gap," alongside its existing CI-check rows.
- [ ] `planifest-docs-agent/SKILL.md`'s Parallelism Directive table includes a MUST-parallelise row for "2+ independent living-doc updates (no shared content dependency)," alongside its existing rows.
- [ ] No existing row is removed or weakened in either skill's Parallelism Directive table or in `agent-dispatch-standards.md`'s MUST/Cannot-parallelise tables.
- [ ] `build-log.md`'s existing "Parallel task batches" field (already tracked per phase, per `plan/current/design.md`'s Architecture Layer) requires no schema change — the pipeline-efficiency NFR is measured against this existing field, not a new one.

## Dependencies
- `planifest-framework/standards/agent-dispatch-standards.md` — canonical home for the Parallelism Rules; both phase-skill changes reference it and must stay consistent with it.
- `planifest-validate-agent/SKILL.md` (P4) and `planifest-docs-agent/SKILL.md` (P6) — the two phase skills named as the minimum audit scope in the feature brief's acceptance criteria.
