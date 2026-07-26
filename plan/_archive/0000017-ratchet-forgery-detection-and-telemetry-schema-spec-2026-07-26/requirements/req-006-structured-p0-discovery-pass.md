---
title: "Requirement: req-006 - structured-p0-discovery-pass"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-006 - structured-p0-discovery-pass

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Source:** US-006
**Priority:** must-have

---

## User Story

As a human starting P0 in any adoption mode, I see a structured discovery pass run before coaching begins, with its findings written to `discovery.md` — separate from the audit trail and the confirmed design — so that I can see exactly what the orchestrator already knows before it starts asking me questions.

---

## Functional Requirements
- Every adoption mode (Greenfield, Standard Iterative, Retrofit, External Anchor) performs a structured discovery pass at the start of P0, before coaching begins
- Findings are written to `plan/current/discovery.md`, separate from `build-log.md` (Q&A audit trail) and `design.md` (curated confirmed output)
- Per-mode content:
  - **Greenfield:** adoption-mode signal (none found, default), repo instructions from `planifest-overrides/instructions/` (or "None"), git pre-flight state, version baseline `0.1.0`, skills-inbox scan result
  - **Standard Iterative:** version from `docs/about.md`, summary of prior features from `plan/_archive/` (feature IDs/dates/one-liners), prior ADRs that constrain this feature unless superseded, existing component/data-ownership map from `docs/`, git pre-flight state, skills-inbox scan
  - **Retrofit:** existing 6-step scan (entry points, components, data ownership, API contracts, patterns, tech debt) plus suggested version from `package.json`/`go.mod`/git tags/README, git pre-flight state
  - **External Anchor:** full `external-versioning.md` contents/constraints, plus whichever underlying mode's content applies based on what else is present in the repo, git pre-flight state
  - All 4 modes share a common header: adoption-mode detection result + signal, git pre-flight findings, skills-inbox scan
- `discovery.md` is fresh every pipeline run: filed to `plan/_archive/{feature-id}-{date}/` alongside `build-log.md`/`design.md` at P7, brand-new copy created at the next P0
- A partial discovery-pass failure (malformed input file, corrupted archive entry, failed pre-flight check, etc.) leaves the affected section stating plainly it couldn't be determined; coaching proceeds on the rest — never a hard block
- On session resume within a still-in-progress pipeline run, the existing `discovery.md` is trusted as-is, not re-run; if missing or incomplete, it is regenerated fresh rather than patched

## Acceptance Criteria
- [ ] `discovery.md` is created before the first coaching question, in every adoption mode
- [ ] Content matches the per-mode specification above
- [ ] `discovery.md` is archived at P7 and a fresh copy is created at the next P0
- [ ] A partially failed discovery pass produces an inline note in the affected section, not a blank section or a hard block
- [ ] Resume within a pipeline run trusts the existing `discovery.md`; a missing/incomplete file is regenerated, not patched

## Dependencies
- `planifest-orchestrator` Adoption Modes section rewrite (all 4 modes)
- `design.template.md` reference update (points to `discovery.md` instead of embedding findings)
