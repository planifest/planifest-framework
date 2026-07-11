---
title: "Requirement: REQ-005 - Orchestrator Product-Version Detection"
summary: "P0 version suggestion reads product.yml when present, alongside docs/about.md."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-005 - Orchestrator Product-Version Detection

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-005
**Priority:** must-have
**Wave:** 0

---

## User Story

As the orchestrator at P0, I read `product.yml` (when present) alongside `docs/about.md` to suggest the next version, so that version suggestions are correct for multi-component projects.

---

## Functional Requirements
- P0 Start Action 3b (Read version) additionally reads `product.yml` when it exists; the product-level version takes precedence over `docs/about.md` as the "last known version" for the bump suggestion
- When `versionPolicy: external` is set, the orchestrator does not suggest a bump — it presents the external-anchor constraint and asks the human (consistent with External Anchor adoption mode)
- When `product.yml` is absent, behaviour is unchanged from today (docs/about.md + archive cross-reference)

## Acceptance Criteria
- [ ] P0 on a fixture with `product.yml` suggests the bump from the product version, not the component version
- [ ] P0 on a fixture with `versionPolicy: external` asks the human instead of suggesting
- [ ] P0 without `product.yml` behaves exactly as pre-feature

## Dependencies
- REQ-003 (manifest format)
