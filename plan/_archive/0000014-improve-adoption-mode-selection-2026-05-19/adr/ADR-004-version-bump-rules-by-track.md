---
title: "ADR-004: Version Bump Rules by Pipeline Track"
summary: "Version bumps follow a track-keyed semver policy: Fast Path and Change Pipeline produce patch bumps; Feature Pipeline produces minor bumps; major breaking changes produce major bumps."
status: "accepted"
version: "0.1.0"
---
# ADR-004 - Version Bump Rules by Pipeline Track

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000014-improve-adoption-mode-selection
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-19

---

## Context

With `docs/about.md` established as the version source (ADR-003), a policy is needed for how the version is bumped at each pipeline run. The policy should be derivable from information already available at P0 (the pipeline track) and should produce a meaningful version history without requiring the human to reason about semver from scratch each time.

---

## Decision

**Version bump rules are keyed to the pipeline track:**

| Track | Bump type | Example |
|-------|-----------|---------|
| Fast Path | patch | 0.5.0 → 0.5.1 |
| Change Pipeline | patch | 0.5.0 → 0.5.1 |
| Feature Pipeline | minor | 0.5.0 → 0.6.0 |
| Major breaking changes | major | 0.5.0 → 1.0.0 |
| Greenfield (first run) | n/a | 0.1.0 (fixed start) |
| External Anchor | n/a | human-provided |

The agent suggests the bump; the human always confirms. For major bumps, the agent must cite the specific rationale (breaking change, architectural reset, etc.) before asking for confirmation.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Human decides the version every time with no suggestion | Maximum control | Cognitive overhead; inconsistent version history | Rejected — defeats the purpose of a suggestion mechanism |
| Always minor bump | Simple | Fast Path fixes inflate minor version inappropriately | Rejected — semantic mismatch |
| Semver based on diff analysis (automated) | Precise | Requires code analysis tooling; not applicable to skill file changes | Rejected — over-engineered for this context |
| Track-keyed rules with human confirmation (this decision) | Predictable; consistent; human retains final control | Agent doesn't analyse the actual diff; may occasionally suggest wrong tier | Chosen — best balance of automation and human oversight |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator skill | Version suggestion logic added at P0 |

---

## Consequences

**Positive:**
- Version history is semantically meaningful — minor versions correspond to features, patches to fixes
- Human only needs to confirm or override, not reason from scratch
- Policy is simple enough to explain in one sentence

**Negative:**
- The agent doesn't inspect the actual change content — a large Change Pipeline run (many components) still gets a patch bump
- Major version suggestion relies on the human (or agent) recognising "major breaking" — this is subjective

**Risks:**
- Version inflation if Feature Pipeline runs are frequent and the human always accepts minor bumps; mitigated by the human confirmation step and the regression guard

---

## Related ADRs

- ADR-003 — depends-on (version source must exist for bump rules to apply)
- ADR-005 — extends (regression guard protects the version produced by these rules)

---

## Supersedes

- None

## Superseded By

- None
