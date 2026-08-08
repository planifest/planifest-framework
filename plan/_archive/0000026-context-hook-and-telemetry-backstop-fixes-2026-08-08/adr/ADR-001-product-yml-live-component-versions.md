---
title: "ADR 001: product.yml components[] as Path Pointers, Not Cached Versions"
summary: "Under versionPolicy max-component-version, product.yml's components[] now stores {id, path} pointers to each component's own component.yml, read live by product-version.mjs at derivation time, instead of a cached {id, version} copy that could drift out of sync."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - product.yml components[] as Path Pointers, Not Cached Versions

**Skill:** [adr-agent](../../../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Feature:** 0000026-context-hook-and-telemetry-backstop-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

0000016-ADR-002 introduced `product.yml` to aggregate one release version across a project's components, with `components[]` holding a cached `{id, version}` per component under `versionPolicy: max-component-version`. That cache went stale the moment a component's own `component.yml` bumped its version outside a P9 ship: `context-mode-hooks` bumped 0.2.0 → 0.2.1 mid-PC during this feature's own 0000042 fix, and `product.yml` never got the update, only surfacing when this feature reached its own ship-review version-bump question. ADR-002's own alternatives analysis weighed "each component.yml claims the product version" (rejected: no single owner) against "always derive max, no manifest" (rejected: no support for `explicit`/`external` policies) — it never considered a third option that keeps single ownership without ever needing a cached copy.

## Decision

Under `versionPolicy: max-component-version`, `components[]` entries hold `{id, path}` — a pointer to that component's own `component.yml` — instead of `{id, version}`. `product-version.mjs` reads each referenced `component.yml`'s live `version:` field at derivation time and takes the highest. `components[]` now only needs editing when a component is added or removed, never on a version bump. The `explicit` and `external` policies are unaffected — they never read `components[]` for version derivation. `product.yml`'s own top-level `version` field remains informational under `max-component-version` (last value ship-agent tagged) and stays authoritative only under `explicit`.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Keep cached `{id, version}`, add a P0/P9 consistency check that fails loudly on drift | No shape change; smaller diff | Still requires remembering to sync on every component version bump; a check only catches drift after it happens, doesn't prevent it | Treats the symptom, not the cause — the cache itself is the defect |
| Drop `product.yml`'s `components[]` entirely; have `product-version.mjs` glob for all `component.yml` files under the project root | No explicit list to maintain at all | No way to scope which components count toward the product version (a project could have `component.yml` files that are examples, templates, or intentionally excluded); loses the explicit single-owner list ADR-002 established | Removes a real capability (deliberate component inclusion) to save a few lines in `product.yml` |
| Keep `{id, version}` but require ship-agent to `grep` and sync it as a mandatory, checked P9 sub-step | No shape change | Exactly the manual-sync process that already existed and already failed once during this feature's own run | Doesn't fix the mechanism, just adds process on top of a mechanism proven to be missed |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | `product.template.yml`, `product-version.mjs`, `planifest-ship-agent/SKILL.md` Step 9, `test-0000016-pipeline-governance.sh` (+ promoted regression copy) updated; new migration `planifest-framework/migrations/migrate-product-yml-component-paths.md` for adopter projects with an existing old-shape `product.yml` |

## Consequences

**Positive:**
- Eliminates the class of defect that prompted this ADR — nothing in `product.yml` can go stale relative to a component's own version, because nothing is cached
- `components[]` maintenance burden drops to exactly when it should change: component added or removed

**Negative:**
- `product-version.mjs` now does file I/O per component (reads each referenced `component.yml`) instead of pure string parsing of one file — negligible at this scale (single-digit components), noted for completeness
- Existing adopter projects with an old-shape `product.yml` hit a hard failure (exit 2) at their next P9 tag under `max-component-version` until they run the new migration — not silent breakage, but a blocking one

**Risks:**
- A `components[]` entry with a `path` pointing at a moved/renamed/deleted `component.yml` fails loudly (exit 2, named path in the error) rather than silently — treated as a positive (fail loud, not stale-silent) but noted as a new failure mode that didn't exist before this change

## Related ADRs

- 0000016-ADR-002 - amends (this ADR is the amendment; see that ADR's own "Superseded By" note)

## Supersedes

- None (amends 0000016-ADR-002's `components[]` shape specifically; the rest of ADR-002 — the `product.yml` file's existence, `versionPolicy` enum, single-ownership model — is unchanged)

## Superseded By

- None
