---
title: "ADR 002: Framework Update Policy as a new P0 step, not a migrator extension"
summary: "Adds a dedicated P0 Start Actions step detecting a planifest-framework/ dependency update, gated on human confirmation of both the update and its provenance, rather than extending planifest-migrator or introducing a new standalone skill."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - Framework Update Policy as a new P0 step, not a migrator extension

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

Backlog `0000046` (this feature's req-005) reported that downstream repo workflows have no distinct treatment for "the `planifest-framework/` folder is being updated to a newer version" versus "unrecognised code is being pushed from an unknown source." Two downstream-filed backlog entries (`0000040`, `0000041`) already reference "this repo's Framework Update Policy" by name, but no canonical mechanism defines it. `planifest-migrator` exists but its scope is narrowly "read one pending migration file, present findings, apply confirmed changes, archive it" — a single-migration-file I/O shape. A framework-folder update (an entire `planifest-framework/` copy arriving from an upstream release) is a different-shaped problem: detecting that an update occurred at all, and confirming its provenance, precede and are independent of whether any migration files happen to accompany it.

## Decision

Add a new P0 Start Actions step to the orchestrator (`planifest-orchestrator/SKILL.md`), positioned alongside the existing migration-scan step, that: (1) detects a `planifest-framework/` dependency update (e.g. a version mismatch between the installed `planifest-framework/component.yml` version and a previously recorded value, or the arrival of framework files with a newer declared version than what the repo last ran a pipeline against), (2) surfaces this to the human as its own distinct decision — never silently applied, never conflated with ordinary feature-brief coaching — and (3) requires explicit human confirmation of both the update itself and its stated provenance (upstream release, commit, or migration that produced the files) before treating the new files as trusted. Document the resulting mechanism in a new `planifest-framework/standards/framework-update-policy.md`, so `0000040`/`0000041`-style references resolve to something real. `planifest-migrator` is unchanged — it continues to own the narrower "process one pending migration file" flow, invoked from this same P0 area when a migration happens to exist.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Extend `planifest-migrator` to also handle whole-folder update detection/provenance | One fewer skill file to maintain | Conflates two different I/O shapes (one-migration-file vs whole-folder-update-detection) in one skill; migrator's existing "read a migration file" contract would need a second, unrelated entry point | Mixing concerns makes both harder to reason about and test independently |
| A new standalone dedicated skill/agent | Maximum separation of concerns | This is a P0-only, human-confirmation-gated check with no multi-step agentic work of its own — a whole skill file is disproportionate to the actual mechanism (a detection check + a confirmation question), and conflicts with this same feature's req-008 minimal-process spirit | Not justified by the actual complexity of the mechanism |
| Leave it as prose guidance only, no structural change | Zero implementation cost | This is exactly the failure mode `0000016-ADR-007` already rejected for telemetry — an unstructured update could still slip through without the human noticing what changed or where it came from | Rejected for the same reason ADR-001 rejected prose-only enforcement for telemetry |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | New P0 Start Actions step in the orchestrator; new `framework-update-policy.md` standards doc; `planifest-migrator` invocation point unchanged but now explicitly scoped narrower in the new doc |

## Consequences

**Positive:**
- `0000040`/`0000041` and any future downstream entries referencing "the Framework Update Policy" now point at a real, documented mechanism instead of an assumed one.
- Keeps `planifest-migrator` focused on its existing, working contract rather than overloading it.

**Negative:**
- One more P0 Start Actions step for every pipeline run to execute (mitigated: it's a cheap detection check, a no-op when no update is present, consistent with the framework's existing pattern of several small P0 pre-flight checks).

**Risks:**
- Version-mismatch detection could false-positive on a repo that manually edited `component.yml`'s version field without an actual framework update — mitigate by keying detection on the presence of new/changed files under `planifest-framework/` since the last recorded pipeline run, not solely the version string, at P3 implementation time.

## Related ADRs

- 0000016-ADR-002 - related-to (product.yml as versioning source of truth — the detection signal this ADR's mechanism reads)
- 0000016-ADR-007 - depends-on (deterministic enforcement precedent, same rationale as ADR-001 in this feature)

## Supersedes

- None

## Superseded By

- None
