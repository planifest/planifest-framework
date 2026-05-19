---
title: "Changelog - 0000014-improve-adoption-mode-selection"
summary: "PR changelog for 0000014 — improved P0 adoption mode selection."
status: "complete"
version: "0.14.0"
---
# Changelog - 0000014-improve-adoption-mode-selection

**Feature ID:** `0000014-improve-adoption-mode-selection`
**Version:** `0.14.0`
**Date:** 2026-05-19
**PR:** {pending — updated after PR is raised}

---

## Summary

Improved the Planifest orchestrator's Phase 0 experience with a visible, signal-driven adoption mode selection, a structured version suggestion protocol, and a Scope Lock Challenge to surface scenario gaps before design lock. Also introduced the one-question-at-a-time rule as a framework-wide standard across all 9 phase skills.

---

## What Changed

### planifest-framework/skills/planifest-orchestrator/SKILL.md
- **Four adoption modes** (Greenfield, Standard Iterative, Retrofit, External Anchor) replace the undocumented three-mode model including the ambiguous "Agent Interface Layer"
- **Signal-based auto-detection** at P0 start (step 3a) with priority order: External Anchor > Standard Iterative > Retrofit > Greenfield
- **Version detection** (step 3b): reads `docs/about.md`, suggests a bump by pipeline track, hard-blocks version regressions
- **Conflict warnings**: human's stated mode vs. detected signal surfaces a one-question warning before proceeding
- **Scope Lock Challenge**: four scenario path questions (happy, first-run, error, cross-session) derived from the feature, asked one at a time before design gate
- **P0 Audit Trail**: incremental build log writes after each coaching exchange
- **Recommend-then-confirm** pattern documented as the framework-wide interaction standard
- **Gate checklist** updated: adoption mode now validates against all four valid values; version confirmation and Scope Lock completion added as explicit gate items

### planifest-framework/skills/planifest-ship-agent/SKILL.md
- **Step 6b** (new, blocking): creates `docs/` if absent, writes `docs/about.md` from the confirmed version before the archive commit
- `docs/about.md` included in the P7 commit
- One-question rule added to Hard Limits

### planifest-framework/skills/planifest-docs-agent/SKILL.md
- **P6 Gate A**: fails immediately if `docs/` does not exist at repository root
- **P6 Gate B**: agent assesses whether living docs need updating, makes a recommendation, human confirms — one question, one decision
- One-question rule documented in P6 Gate section

### All 9 phase skills
- One-question-at-a-time rule added to each skill's Rules/Hard Limits section
- Specs for when to lead with a recommendation before asking

### planifest-framework/templates/
- `design.template.md`: fixed bug — adoption mode field now shows `greenfield | standard-iterative | retrofit | external-anchor` (was `greenfield | retrofit | agent-interface`)
- `about.template.md`: new template for `docs/about.md`
- `feature-brief.template.md`: added `## Scenario Paths` section with four path prompts before Acceptance Criteria

### planifest-framework/migrations/
- New migration: `migrate-adoption-mode-and-about-md.md`
  - Part A: scans archived `design.md` files, auto-detects correct adoption mode, presents corrections one-at-a-time
  - Part B: initialises `docs/about.md` by suggesting the most recent archive version, human confirms
  - Resumable via `migrations/_progress/` JSON progress file (per ADR-006)

---

## ADRs Produced

| ADR | Decision |
|-----|---------|
| ADR-001 | Four Adoption Mode Taxonomy |
| ADR-002 | Signal Conflict Priority Order |
| ADR-003 | docs/about.md as Canonical Version Source |
| ADR-004 | Version Bump Rules by Pipeline Track |
| ADR-005 | Version Regression Hard Block |
| ADR-006 | Resumable Migration with Progress File |
| ADR-007 | Derived Scope Lock Scenarios over Fixed Checklist |
| ADR-008 | One-Question-at-a-Time as Framework-Wide Instruction |
| ADR-009 | Incremental P0 Audit Trail Writes |
| ADR-010 | docs/ Lifecycle Ownership |

---

## Skipped Phases

None.

---

## Requirements Count

17 requirements (REQ-001 through REQ-017). All implemented.
