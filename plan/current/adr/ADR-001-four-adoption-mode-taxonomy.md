---
title: "ADR-001: Four Adoption Mode Taxonomy"
summary: "Replace the prior three-mode adoption model (Greenfield, Retrofit, Agent Interface Layer) with a four-mode taxonomy: Greenfield, Standard Iterative, Retrofit, External Anchor."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Four Adoption Mode Taxonomy

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000014-improve-adoption-mode-selection
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-19

---

## Context

The Planifest orchestrator previously documented three adoption modes: Greenfield, Retrofit, and Agent Interface Layer. In practice, the modes were poorly defined and inconsistently applied. "Agent Interface Layer" was undocumented in the routing reference, the mode was never explicitly surfaced to the human during P0, and the design template always persisted the value as "retrofit" regardless of what the human selected. A fourth real pattern existed but was unnamed: the common case of an ongoing Planifest project building its next feature, which is neither a fresh start (Greenfield) nor an onboarding exercise (Retrofit).

---

## Decision

Replace the three-mode taxonomy with four explicitly defined and signal-driven modes:

- **Greenfield** — new project, no prior codebase, no `docs/about.md`. Starting version: `0.1.0`.
- **Standard Iterative** — ongoing Planifest project. Signal: `docs/about.md` exists. Version read from file.
- **Retrofit** — existing codebase without Planifest history. Signal: codebase present, no `docs/about.md`. Human confirms current version.
- **External Anchor** — an external component dictates versioning. Signal: `planifest-overrides/instructions/external-versioning.md` exists. Human provides version directly.

"Agent Interface Layer" is retired: it was conceptually valid (building against an external spec) but its versioning behaviour is identical to External Anchor, and its naming was confusing. The External Anchor mode subsumes its intent with a clearer trigger mechanism.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Keep three modes, add Standard Iterative | Smaller change surface | "Agent Interface Layer" remains poorly defined and undocumented | Still leaves the naming confusion; two overlapping modes (Agent Interface + External Anchor) |
| Keep three modes, rename Agent Interface to External Anchor | Minimal renaming effort | Loses the opportunity to make Standard Iterative explicit | The most common mode (ongoing project) remains unnamed and undetected |
| Two modes only (Greenfield / Existing) | Maximum simplicity | Collapses meaningfully different situations into "existing" | Versioning logic and P0 coaching differ significantly between Retrofit and Standard Iterative |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator skill | Rewrites adoption mode detection and selection step |
| design.template.md | Field values updated to four-mode list |
| planifest-migrator | Migration corrects archived design.md files that have wrong mode values |
| All phase skills | Coaching references to adoption mode updated |

---

## Consequences

**Positive:**
- The most common pipeline mode (ongoing project) is now explicitly named and detected
- Adoption mode is determined by file signals, not guessed from context
- "Agent Interface Layer" ambiguity is eliminated

**Negative:**
- Existing archived design.md files record incorrect or legacy mode values — requires a migration (REQ-008)
- Any documentation or external references to "agent-interface" as a mode value break

**Risks:**
- The migration's best-guess adoption mode detection for archives may be wrong for ambiguous features; human confirmation mitigates this but adds friction

---

## Related ADRs

- ADR-002 — depends-on (signal priority order depends on four modes being defined)
- ADR-003 — depends-on (version source depends on mode taxonomy)

---

## Supersedes

- None (no prior ADR existed for the three-mode model)

## Superseded By

- None
