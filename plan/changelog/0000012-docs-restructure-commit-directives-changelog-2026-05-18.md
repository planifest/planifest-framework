---
title: "Changelog - 0000012-docs-restructure-commit-directives"
type: changelog
---

# Changelog — 0000012-docs-restructure-commit-directives — 18 May 2026

**Feature:** Docs restructure, commit directives, and P0–P9 formalisation
**Pipeline run:** P0, P1, P2, P3 (×2), P4 (×2), P5 (×2), P6 (×2), P7, P8, P9
**PR:** pending — updated after PR is raised

---

## What Was Built

Restructured Planifest framework documentation into three purpose-specific files. Formalised the pipeline as exactly P0–P9, adding P9 Ship as a discrete phase and renaming P7 to Archive. Enforced build log completeness (Hard Limit 8) and run-mode persistence. Added P0 pre-flight branch check, git tagging at ship time, and a Planifest migration for retroactive release tags (v0.1–v0.10). A second P3–P6 cycle incorporated three post-P6 recommendations before shipping.

---

## Artifacts Produced

**Requirements (13):**
- REQ-001 through REQ-010 (original scope)
- REQ-011: P8 sub-agent explicit model tier
- REQ-012: Resume Detection run-mode step
- REQ-013: Iteration log vs changelog ownership clarification

**ADRs (6):**
- ADR-001: Three-file documentation architecture
- ADR-002: Formal P9 Ship phase
- ADR-003: Ship-agent orchestrates P7–P9
- ADR-004: P9 human push/PR decision protocol
- ADR-005: Run-mode sentinel file
- ADR-006: Retroactive tags via Planifest migration

**Framework files modified:**
- `planifest-framework/getting-started.md` (via patch 001)
- `planifest-framework/pipeline-reference.md` (via patch 001 + P3)
- `planifest-framework/project-operations.md` (via patch 001)
- `planifest-framework/skills/planifest-orchestrator/SKILL.md`
- `planifest-framework/skills/planifest-ship-agent/SKILL.md`
- `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md`
- `planifest-framework/templates/iteration-log.template.md`
- `planifest-framework/migrations/retroactive-release-tags.md` (new)

**Living docs updated:**
- `docs/decisions-index.md`
- `docs/architecture-overview.md`
- `docs/component-registry.md`

---

## Decisions

- **ADR-001:** Three-file documentation architecture — single-audience files replacing monolithic doc
- **ADR-002:** P9 Ship is a formal phase — pipeline is exactly P0–P9; no phase outside this range
- **ADR-003:** Ship-agent owns P7–P9 — archive, build assessment sub-agent, and ship as one close-out
- **ADR-004:** P9 always presents human push/PR choice — never auto-pushes without awareness
- **ADR-005:** `plan/.run-mode` persists run mode across session boundaries; fail-safe defaults to `interactive`
- **ADR-006:** Retroactive git tags applied via migration file — human-confirmed per tag, local-only until human pushes

---

## Skipped Phases

None
