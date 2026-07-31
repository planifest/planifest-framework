---
title: "ADR 001: Repository self-description CI check is a separate script, not an extension of consistency-check.mjs"
summary: "req-005 (0000018) adds a new repository-scoped script for README-vs-filesystem drift, rather than folding the check into the existing plan/current/ consistency-check.mjs."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Repository self-description check is a separate script

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Tool:** Claude Code
**Model:** claude-sonnet-5
**Feature:** 0000019-self-description-and-session-hygiene-fixes
**Component:** N/A — repository-scoped tooling, not a `src/{component-id}`
**Status:** accepted
**Date:** 2026-07-31

---

## Context

req-001 (0000014) fixes README drift that had gone undetected: wrong counts on five of seven table rows, and two structure-diagram paths that don't resolve. req-005 (0000018) exists so this class of defect doesn't recur silently — CI must fail when the README's structural claims diverge from the repository.

The framework already has `planifest-framework/scripts/consistency-check.mjs`, invoked by the `planifest-design-critic` skill during a feature run to validate `plan/current/` — story traceability, acceptance-criteria counts, ADR resolution, risk mitigations, design scope. The question was whether the new check belongs inside that script or as its own.

The source review's first edition proposed extending `consistency-check.mjs`; its corrected edition reversed that recommendation after examining what the script actually validates and when it runs.

## Decision

Implement the self-description check as a **new, separate, repository-scoped script**, wired into `.github/workflows/planifest.yml` to run on every pull request — not as an added check inside `consistency-check.mjs`.

The two checks differ on every axis that matters for where logic should live:
- **Subject**: `consistency-check.mjs` validates the artifacts of an in-flight feature (`plan/current/`); the new check validates the repository's own self-description (`README.md` against the filesystem it describes).
- **Lifecycle**: `consistency-check.mjs` only has something to say while a feature is in flight, invoked by the design-critic with exit-code semantics tied to that role. Self-description accuracy is a standing repository invariant, checked on every PR regardless of whether a feature is in flight — including PRs that touch no `plan/current/` content at all.
- **Caller**: `consistency-check.mjs` is invoked by an agent skill mid-pipeline. The new check is invoked by CI directly, with no pipeline-phase context.

Combining them would couple a per-feature gate to repository metadata, and would make `consistency-check.mjs` fail (or need to be skipped) in contexts — like a docs-only PR outside any pipeline run — where it currently has nothing to say.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Extend `consistency-check.mjs` with a self-description check | One fewer script to maintain; reuses existing invocation wiring | Couples a per-feature gate to a repository-wide invariant; forces the script to run (or be conditionally skipped) outside any pipeline context; conflates two different lifecycles in one exit code | Rejected — the source review's own corrected edition reversed this after tracing what the script validates and when it's invoked |
| Add the check as a git pre-commit/pre-push hook instead of CI | Catches drift before it's pushed, not just at PR time | Shipped hooks (`planifest-framework/hooks/`) are installed into every consumer repo via `setup.sh`; this check is specific to the framework's own README, not something consumer repos should inherit | Rejected — wrong distribution mechanism; this check belongs to this repository only |
| Do nothing further, rely on manual review to catch future drift | Zero implementation cost | This is exactly the status quo that let req-001's five wrong rows and two broken paths go undetected | Rejected — the whole point of req-005 is to not repeat req-001 |

## Affected Components

| Component | Impact |
|-----------|--------|
| N/A (repository-scoped) | New script added under a repository-scoped path (not `src/{component-id}`); wired into `.github/workflows/planifest.yml` |

## Consequences

**Positive:**
- README structural drift is caught automatically on every PR, closing the exact gap that let req-001's defects accumulate undetected.
- `consistency-check.mjs`'s scope and exit-code semantics stay clean — it continues to mean exactly one thing (P1/P2 artifact validation during a feature run).

**Negative:**
- One more script to maintain, with its own small surface area (path-existence + table-coverage checks) separate from the existing consistency-check tooling.

**Risks:**
- If the new script's path-resolution logic diverges in behaviour from `consistency-check.mjs`'s (e.g. different handling of symlinks or relative paths), the two checks could disagree about what "exists" someday. Low likelihood given both are simple filesystem checks; not mitigated further here as out of scope for this ADR.

---

## Related ADRs

- None yet recorded for this feature area.

---

## Supersedes

- None.

## Superseded By

- None.

---

*Generated by adr-agent. Path: `plan/current/adr/ADR-001-self-description-check-as-separate-script.md`*
