---
title: "Execution Plan - 0000007-agent-optimisation"
status: "active"
version: "0.1.0"
---
# Execution Plan — 0000007-agent-optimisation

## Overview

Two streams of work delivered as one pipeline run:

1. **Build target awareness** — explicit `Build target` field in the feature-brief template; per-tier agent behaviour defined in a new standard; orchestrator, codegen-agent, and validate-agent updated with docker-mode guidance.
2. **Skill file optimisation** — boilerplate removal, stale reference cleanup, template extractions, telemetry consolidation, and language standardisation across the framework skill files; new `planifest-optimise-agent` skill; new language and telemetry standards.

## Delivery Tracks

### Track A — New standards and templates (no dependencies; build first)

| Artifact | Path | Requirement |
|----------|------|-------------|
| Build target standards | `planifest-framework/standards/build-target-standards.md` | req-002 |
| Telemetry standards | `planifest-framework/standards/telemetry-standards.md` | req-005 |
| Design template | `planifest-framework/templates/design.template.md` | req-007 |
| Language quirks | `planifest-framework/standards/language-quirks-en-gb.md` | req-008 |

### Track B — Skill file updates (depend on Track A standards being in place)

All skill updates are independent of each other and MUST be applied in a single parallel batch.

| Artifact | Requirement(s) |
|----------|---------------|
| `planifest-orchestrator/SKILL.md` | req-004, req-005, req-006 (ext-skills, skill-sync, templates list, pipeline-run.md), req-007 (design template JIT row) |
| `planifest-spec-agent/SKILL.md` | req-004 (Hard Limits, footer), req-005, req-006 (context-mode block) |
| `planifest-adr-agent/SKILL.md` | req-004, req-005, req-006 (design-requirements.md path) |
| `planifest-codegen-agent/SKILL.md` | req-002 (docker guidance), req-004, req-005, req-006 (ADR labels) |
| `planifest-validate-agent/SKILL.md` | req-002 (docker guidance), req-004, req-005, req-006 (pipeline-run.md, standards list) |
| `planifest-security-agent/SKILL.md` | req-004 (Hard Limits, footer, Role Boundary), req-005, req-006 (design-requirements.md path) |
| `planifest-docs-agent/SKILL.md` | req-004, req-005, req-007 (iteration log JIT) |
| `planifest-ship-agent/SKILL.md` | req-004 (footer), req-005, req-006 (Step 6 ext-skills) |
| `planifest-build-assessment-agent/SKILL.md` | req-004 (footer only) |
| `planifest-change-agent/SKILL.md` | req-004, req-005 |
| `planifest-test-writer/SKILL.md` | req-004 (footer only) |
| `planifest-implementer/SKILL.md` | req-004 (footer only) |
| `planifest-refactor/SKILL.md` | req-004 (footer only) |

### Track C — Template updates (independent of Track B)

| Artifact | Requirement |
|----------|------------|
| `planifest-framework/templates/feature-brief.template.md` | req-001 |

### Track D — Setup script updates (independent)

| Artifact | Requirement |
|----------|------------|
| `planifest-framework/setup.sh` | req-007 (manifest) |
| `planifest-framework/setup.ps1` | req-007 (manifest) |

### Track E — New skill (independent)

| Artifact | Requirement |
|----------|------------|
| `planifest-framework/skills/planifest-optimise-agent/SKILL.md` | req-003 |

### Track F — Global replacement (depends on all Track B/C writes being complete)

| Action | Requirement |
|--------|------------|
| Global `artefact` → `artifact` across all `planifest-framework/` files | req-008 |

### Track G — Tests (depends on all tracks complete)

| Artifact | Path |
|----------|------|
| Test suite | `planifest-framework/tests/test-0000007-agent-optimisation.sh` |

## Non-Functional Requirements

- All changes are Markdown / Bash edits — no runtime dependencies introduced
- No breaking changes to existing hook contracts or telemetry event schemas
- Test suite must pass with zero failures alongside the existing suite

## Build Order

1. Track A (parallel batch — 4 new files)
2. Tracks B, C, D, E (parallel batch — independent edits and new files)
3. Track F (global replacement — after all content writes are done)
4. Track G (tests — last)
