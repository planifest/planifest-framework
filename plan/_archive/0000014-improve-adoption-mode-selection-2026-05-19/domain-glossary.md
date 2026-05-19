---
title: "Domain Glossary - 0000014-improve-adoption-mode-selection"
---
# Domain Glossary - 0000014-improve-adoption-mode-selection

**Adoption mode** — one of four states that describes the relationship between the current pipeline run and the existing codebase: Greenfield, Standard Iterative, Retrofit, or External Anchor.

**Greenfield** — adoption mode for a brand-new project with no prior codebase and no `docs/about.md`. Suggested starting version: `0.1.0`.

**Standard Iterative** — adoption mode for an ongoing Planifest project. Signal: `docs/about.md` exists. Version is read from `about.md` and bumped by pipeline track.

**Retrofit** — adoption mode for onboarding an existing codebase that has not previously used Planifest. Signal: codebase files present, no `docs/about.md`. Human confirms current version.

**External Anchor** — adoption mode where an external component (outside this repo) dictates the version. Signal: `planifest-overrides/instructions/external-versioning.md` exists. Human provides the version directly. Takes priority over all other modes.

**Signal** — a filesystem artefact whose presence or absence is used to detect an adoption mode (e.g. presence of `docs/about.md` signals Standard Iterative).

**Signal conflict** — the condition where multiple adoption mode signals are present simultaneously. Resolved by the priority order: External Anchor > Standard Iterative > Retrofit > Greenfield.

**Version regression** — the act of confirming a version number lower than the currently recorded version. Hard-blocked by the orchestrator.

**Scope Lock Challenge** — a structured step at the end of P0 coaching where the orchestrator derives and asks happy/sad/bad path scenario questions from the specific feature being built, before the design is presented for confirmation.

**Happy path** — the end-to-end scenario where all inputs are valid, all systems are available, and the feature operates as designed.

**Sad path** — a recoverable failure scenario: something goes wrong but the system handles it gracefully (e.g. `about.md` version is malformed — agent falls back to archive history).

**Bad path** — an unrecoverable or silently propagating failure scenario (e.g. version regression accepted without warning, corrupting the version history).

**P0 audit trail** — the structured coaching log appended to the P0 build log section after each question-answer exchange. Records question asked, answer summary, and outcome (accepted / overridden / deferred).

**One-question rule** — the framework-wide instruction that every phase skill may ask at most one question per response, and must frame questions as recommendations with confirmation requests rather than open-ended queries.

**Recommend-then-confirm** — the question pattern required by the one-question rule: agent assesses, makes a recommendation, asks "does that work?" rather than "what do you want to do?".

**Migration** — a file in `planifest-framework/migrations/` that describes a one-time change to be applied to an existing Planifest project, executed interactively by `planifest-migrator`.

**Progress file** — a JSON file in `planifest-framework/migrations/_progress/` that tracks which archives a migration has already processed, enabling resumable runs.

**`docs/about.md`** — the living project-level file that records the current version, last-updated feature, and update date. Read at P0, written at P7.

**`external-versioning.md`** — an override instruction file in `planifest-overrides/instructions/` that activates External Anchor mode and describes the external versioning constraint.

**Scenario Paths** — a section in the Feature Brief template prompting the human to describe the happy path, first-run path, error/sad path, and cross-session continuity path before the coaching conversation begins.
