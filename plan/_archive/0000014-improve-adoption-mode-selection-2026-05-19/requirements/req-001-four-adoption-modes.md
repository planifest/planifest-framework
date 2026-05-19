---
title: "Requirement: REQ-001 - Four Adoption Modes"
summary: "Define four adoption modes with detection signals for each."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-001 - Four Adoption Modes

**Skill:** planifest-orchestrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- The orchestrator recognises exactly four adoption modes: Greenfield, Standard Iterative, Retrofit, External Anchor
- Each mode has explicit detection signals checked at P0 before any coaching begins
- Greenfield signal: no existing codebase files and no `docs/about.md`
- Standard Iterative signal: `docs/about.md` exists
- Retrofit signal: existing codebase files present but no `docs/about.md`
- External Anchor signal: `planifest-overrides/instructions/external-versioning.md` exists (takes priority over all other signals)
- Detection logic reads signals in priority order: External Anchor first, then Standard Iterative, then Retrofit, then Greenfield

## Acceptance Criteria
- [ ] Orchestrator detects External Anchor when `planifest-overrides/instructions/external-versioning.md` is present, regardless of other signals
- [ ] Orchestrator detects Standard Iterative when `docs/about.md` exists and External Anchor signal is absent
- [ ] Orchestrator detects Retrofit when codebase files exist, `docs/about.md` is absent, and External Anchor signal is absent
- [ ] Orchestrator detects Greenfield when no codebase files and no `docs/about.md` exist
- [ ] Detection runs before any coaching questions are asked

## Dependencies
- REQ-002 (mode selection step that presents the detected mode)
- REQ-009 (signal conflict priority order and fallback logic)
