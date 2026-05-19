---
title: "ADR-003: docs/about.md as Canonical Version Source"
summary: "The project version is stored in docs/about.md (YAML frontmatter), read at P0 and written at P7, rather than in component.yml, git tags, or plan/ artifacts."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - docs/about.md as Canonical Version Source

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000014-improve-adoption-mode-selection
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-19

---

## Context

To support the adoption mode selection and version suggestion protocol (REQ-003, REQ-004), a single authoritative source of the current project version is required. This source must be:
1. Readable at P0 before any plan/ artifacts are written
2. Writable at P7 as part of the close-out sequence
3. Human-readable and not coupled to a specific component
4. Stable across pipeline runs (not a transient plan/ artifact)

Several candidates were considered: `planifest-framework/component.yml`, git tags, `plan/` artifacts, and a new dedicated file.

---

## Decision

**`docs/about.md` is the canonical version source**, with YAML frontmatter fields: `version`, `feature`, `updated`.

`docs/` is the living state layer — it reflects what the repo currently is. This aligns with the existing Planifest convention where `docs/` holds current-state artifacts and `plan/` holds change artifacts. A file in `docs/about.md` is:
- Persistent across pipeline runs (not archived with `plan/current/`)
- Not component-specific (unlike `component.yml`)
- Always-permitted by the gate-write hook (docs/ prefix)
- Readable at P0 with no dependency on plan/ state

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| `planifest-framework/component.yml` version field | Already exists; already bumped at P9 | Component-specific; represents the framework version not the project version; not applicable to non-framework repos | Rejected — wrong semantic scope |
| Git tags (e.g. `v0.13.0`) | Standard semver practice | Requires git access at P0; tags are set at P9 after archiving — circular dependency | Rejected — timing conflict |
| `plan/current/` artifact | Easy to write alongside other plan/ files | Archived at P7 and deleted from current/ — gone before the next pipeline run reads it | Rejected — wrong lifecycle |
| `docs/about.md` (this decision) | Persistent, always-permitted, human-readable, correct lifecycle | New file; requires migration to initialise on existing projects | Chosen — best fit for the required lifecycle and access pattern |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator skill | Reads `docs/about.md` at P0 for version detection |
| planifest-ship-agent skill | Writes `docs/about.md` at P7 as a blocking step |
| planifest-framework/templates/ | New `about.template.md` added |
| docs/ | New living artifact `about.md` introduced |

---

## Consequences

**Positive:**
- Version is always readable at P0 without depending on prior pipeline artifacts
- Consistent with the docs/ = living state convention
- Migration initialises the file for existing projects

**Negative:**
- Existing projects require a one-time migration to create `docs/about.md`
- A new file type and lifecycle obligation are introduced

**Risks:**
- If `docs/about.md` is manually edited to an incorrect version, the regression guard (REQ-009) will block the next pipeline run; human must understand they need to re-version archives to reset

---

## Related ADRs

- ADR-001 — depends-on (Standard Iterative mode is signalled by docs/about.md existence)
- ADR-004 — depends-on (version bump rules read from this source)
- ADR-010 — related-to (docs/ lifecycle initialisation)

---

## Supersedes

- None

## Superseded By

- None
