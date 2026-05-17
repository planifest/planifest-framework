---
title: "Requirement: REQ-013 - docs/ must be populated as living documentation of repo state"
summary: "The docs/ directory at the repo root should document current system state as living docs. Plans document change; docs document what exists. The docs-agent must maintain docs/ continuously, not just produce per-pipeline artifacts."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-013 - docs/ must be populated as living documentation of repo state

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** Human requirement — docs/ at repo root is not consistently populated; docs-agent produces per-pipeline artifacts but does not maintain living docs reflecting current repo state across pipeline runs.
**Priority:** must-have

---

## User Story
As a developer onboarding to a Planifest repo, I want to read docs/ and understand the current state of the system — what components exist, what they do, how they connect — without having to read through plan archives or source code.

## Functional Requirements
- `planifest-framework/skills/planifest-docs-agent/SKILL.md` must define `docs/` as the living documentation layer with a clear mandate: docs/ reflects what the repo currently is; plan/ reflects what is changing or has changed
- The docs-agent must maintain the following living docs in `docs/` on every pipeline run, updating rather than recreating them:
  - `docs/component-registry.md` — one entry per component: name, purpose, owner, version, status (existing, confirmed present)
  - `docs/dependency-graph.md` — component dependency map (existing, confirmed present)
  - `docs/architecture-overview.md` — high-level system description, updated after each pipeline run to reflect current components and their relationships
  - `docs/api-index.md` — index of all public API endpoints across all components (if any expose APIs); updated per run; omitted if no API components exist
  - `docs/decisions-index.md` — index of all ADRs across all archived features, with one-line status (active, superseded, amended); updated per run
- Each living doc must include a `Last updated:` field at the top with the feature ID that last modified it
- The docs-agent skill must distinguish between: (a) living docs that must always be updated, (b) per-component docs written once and amended, (c) per-pipeline artifacts that are archived with the plan
- `planifest-framework/templates/` must include a template for each new living doc type introduced by this requirement (`architecture-overview.template.md`, `api-index.template.md`, `decisions-index.template.md`)
- The orchestrator skill must reference docs/ as the living state layer in Phase 0 coaching, so humans understand the distinction between plan/ and docs/

## Acceptance Criteria
- [ ] `planifest-docs-agent/SKILL.md` contains an explicit section defining docs/ as the living documentation layer, distinct from plan/ (change artifacts) and src/{id}/docs/ (component-local docs)
- [ ] The docs-agent skill lists the mandatory living docs to maintain on every run: component-registry, dependency-graph, architecture-overview, api-index (conditional), decisions-index
- [ ] The docs-agent skill specifies that living docs are updated (not recreated) on each run — no destructive overwrite that loses historical context
- [ ] The docs-agent skill specifies the `Last updated: {feature-id}` field requirement for all living docs
- [ ] `planifest-framework/templates/architecture-overview.template.md` exists
- [ ] `planifest-framework/templates/api-index.template.md` exists
- [ ] `planifest-framework/templates/decisions-index.template.md` exists
- [ ] `planifest-orchestrator/SKILL.md` references docs/ as the living state layer in at least one coaching or phase description section

## Dependencies
- Existing `docs/component-registry.md` and `docs/dependency-graph.md` are already produced by the docs-agent — this requirement extends and formalises what already partially exists
- REQ-009 (non-pipeline skills routing) is independent — may proceed in parallel
