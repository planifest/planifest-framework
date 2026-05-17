---
title: "ADR-004: Build Assessment as a separate Phase 8 skill"
status: "accepted"
date: "03 May 2026"
---
# ADR-004: Build Assessment as a separate Phase 8 skill

## Context

The build report could be produced in two ways:
1. Appended to the ship agent's responsibilities (Phase 7)
2. A separate Phase 8 skill invoked after archiving

## Decision

Implement Phase 8 as a **separate `planifest-build-assessment-agent` skill**, invoked by the ship agent after archiving is complete.

## Consequences

- **Single-responsibility**: the ship agent handles archiving; the assessment agent handles analysis. Neither skill grows bloated.
- **Independently loadable**: the assessment skill can be invoked standalone (e.g., retroactively on an existing build log) without re-running the ship phase
- **Visible in the phase table**: P8 appears in the orchestrator prefix table alongside P0–P7, making it a first-class phase that operators can observe and audit
- **Consistent with existing pattern**: each phase has its own skill; P8 follows the same convention as P1–P7
- **Trade-off**: one more skill file to maintain; mitigated by the fact that P8 is purely read-only (reads build-log.md, writes report) and requires no code generation
