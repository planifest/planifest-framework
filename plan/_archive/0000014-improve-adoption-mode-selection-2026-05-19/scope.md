---
title: "Scope - 0000014-improve-adoption-mode-selection"
---
# Scope - 0000014-improve-adoption-mode-selection

## In

- Four adoption modes: Greenfield, Standard Iterative, Retrofit, External Anchor
- Signal detection priority order: External Anchor > Standard Iterative > Retrofit > Greenfield
- Explicit adoption mode selection step at P0 — labelled, distinct, before coaching begins
- External Anchor detection via `planifest-overrides/instructions/external-versioning.md`
- Version suggestion by pipeline track (patch / minor / major) with human confirmation
- Version detection from `docs/about.md` + archive history
- Version regression hard block
- `about.template.md` new template
- `docs/about.md` read at P0, written at P7 (blocking)
- `docs/` initialised at P0; ship-agent creates it at P7 if absent
- Conflict warnings on mode or version override
- Bug fix: `design.template.md` adoption mode field always persisting as "retrofit"
- Migration: correct adoption mode in archived design.md files (resumable, interactive)
- Migration: initialise `docs/about.md` with version from archive history (human confirms)
- Scope Lock Challenge: derived scenarios, one-question-at-a-time, immediate capture loop, formal deferrals
- Structured P0 audit trail written incrementally to build log; feeds P8
- One-question-at-a-time as framework-wide instruction across all 9 phase skills
- Recommend-then-confirm pattern throughout all phases
- P6 Gate A: fail if `docs/` absent
- P6 Gate B: docs update recommendation with human confirmation
- Feature Brief template: Scenario Paths section (happy, first-run, error, cross-session)

## Out

- Runtime code of any kind
- Changes to CI or deployment pipeline
- UI tooling for `docs/about.md`
- Versioning of individual components beyond `planifest-framework/component.yml`
- Automated version tagging in git (this is P9 / ship-agent scope, unchanged)
- Rollback of `docs/about.md` to a prior version

## Deferred

- None
