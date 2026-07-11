---
title: "Requirement: REQ-004 - Ship-Agent Product-Version Tagging"
summary: "Ship-agent P9 derives the release tag from product.yml, with single-component fallback."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-004 - Ship-Agent Product-Version Tagging

**Skill:** planifest-codegen-agent
**Feature:** 0000016-pipeline-governance-and-loop-engineering
**Source:** US-004
**Priority:** must-have
**Wave:** 0

---

## User Story

As the ship-agent at P9, I read the release version from `product.yml` when it exists (falling back to the single `component.yml` in the self-hosted framework-only case), create it with the default `versionPolicy` if missing, and validate it before tagging, so that tagging works generically for both single- and multi-component projects.

---

## Functional Requirements
- At P9, ship-agent reads `product.yml` at project root; if present, the tag version is derived per its `versionPolicy`
- If `product.yml` is absent and the project has exactly one component, existing `component.yml` tagging behaviour applies unchanged
- If `product.yml` is absent and the project has 2+ components, ship-agent creates it from the template with `versionPolicy: max-component-version` before tagging
- An invalid `version` (non-semver) or a version lower than the last tagged version is rejected with a prompt to the human for a manual value — same handling as `component.yml` today

## Acceptance Criteria
- [ ] This repo's own single-component P9 tagging behaviour is byte-identical to pre-feature (existing tests pass unmodified)
- [ ] A seeded multi-component fixture tags correctly under each `versionPolicy` value, including auto-creation on first use
- [ ] A seeded invalid/lower version is rejected with a human prompt, not tagged

## Dependencies
- REQ-003 (product.template.yml and versionPolicy semantics)

## Input Validation
- [ ] Input source: filesystem read of `product.yml` fields (`version`, `versionPolicy`, `components[].version`)
- [ ] Allowed pattern for versions: `^[0-9]+\.[0-9]+\.[0-9]+$`; `versionPolicy` must be one of the three enum values — anything else is rejected
- [ ] Maximum length: 32 characters per version string; 64 per component id
- [ ] Failure behaviour: on invalid value, stop tagging and prompt the human — never tag a fabricated version
- [ ] Logging policy: the offending raw value is shown to the human once in the rejection message; only sanitised values are written to artifacts
