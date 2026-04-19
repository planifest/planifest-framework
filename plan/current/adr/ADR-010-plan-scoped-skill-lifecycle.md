---
id: ADR-010
title: Plan-scoped external skill lifecycle
status: accepted
date: 2026-04-20
deciders: [human-on-the-loop]
---
# ADR-010 — Plan-scoped external skill lifecycle

## Context

REQ-025 defines the lifecycle of externally installed skills. Skills are fetched to support a specific feature; the question is when they should be cleaned up and what the default retention policy should be.

## Decision

External skills are **scoped to the active plan**. The default retention policy is `preserve: false` — skills are removed during P7 (ship/archive) unless the Human on the Loop explicitly opts to keep them.

Cleanup happens at P7 as part of the archive step: the ship-agent lists pending removals, prompts the human for any preservations, then removes all `preserve: false` skills.

## Rationale

1. **Skills are task-specific.** A skill fetched to implement a document-generation feature (e.g. `docx`) is unlikely to be needed after that feature ships. Default cleanup prevents accumulation.
2. **Plan/current as the natural boundary.** `plan/current/` is cleared at P7. External skills follow the same lifecycle — they are a planning-time resource.
3. **Human override for exceptions.** `preserve: true` handles the case where a skill is valuable long-term (e.g. a testing framework skill used across many features). The human decides, not the tool.
4. **Manifest as audit trail.** The `external-skills.yml` manifest records every install with its source, date, and feature context. This is retained even after skills are removed (the manifest entry is deleted, but git history preserves it).

## Alternatives considered

- **Skills persist indefinitely by default:** Rejected. Skills accumulate; agent context bloats; outdated skill instructions could conflict with newer framework versions.
- **Session-scoped (removed on session end):** Rejected. Skills installed for multi-session features would be lost between sessions, requiring re-install.
- **User configures retention policy globally:** Rejected. Adds configuration surface without meaningful benefit over the simple per-skill preserve flag.

## Consequences

- The ship-agent (P7) must be updated to perform skill cleanup as part of its archive step.
- If a human forgets to preserve a useful skill, they can re-install it with `add-skill`.
- The `external-skills.yml` file will typically be empty or absent on a clean repo between features.
