---
title: "ADR-002: planifest-overrides as repo-root sibling directory"
status: "accepted"
version: "0.1.0"
---
# ADR-002 - planifest-overrides as repo-root sibling directory

**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000005-framework-governance
**Status:** accepted
**Date:** 02 May 2026

---

## Context

Human customisations (library overrides, capability skills, repo-specific instructions) currently have no designated home. If they live inside `planifest-framework/`, they are lost when a team upgrades the framework by replacing that directory. A durable location is needed that survives framework upgrades.

---

## Decision

A `planifest-overrides/` directory at the repo root, sibling to `planifest-framework/`. It contains: `library-standards/`, `capability-skills/`, and `instructions/` subdirs. Setup scripts read from it but never write to it. Absence of the directory is a valid no-op — all customisation is optional.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Protected subdir inside `planifest-framework/` (e.g. `planifest-framework/overrides/`) | Single root directory | Any script that replaces `planifest-framework/` wholesale destroys overrides; no clear ownership boundary | Upgrade safety is the primary requirement — this defeats it |
| Dotfile directory (`.planifest-overrides/`) | Convention for tool config | Less discoverable; some tools ignore dotfiles in file pickers | Discoverability matters — humans need to find and edit this without documentation |
| Separate git submodule | Strong isolation | Operational complexity; requires git submodule knowledge; overkill for file-based config | Disproportionate complexity for the use case |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-codegen-agent | Checks `planifest-overrides/library-standards/` first on every manifest scaffold |
| planifest-validate-agent | Checks `planifest-overrides/library-standards/` first on every library audit |
| planifest-orchestrator | Reads `planifest-overrides/instructions/` at P0; reads `planifest-overrides/capability-skills/` via registry |
| setup.ps1/setup.sh | Reads `planifest-overrides/capability-skills/` to generate `external-skills.json`; must contain no writes to `planifest-overrides/` |

---

## Consequences

**Positive:**
- Framework upgrades are safe — replacing `planifest-framework/` cannot affect `planifest-overrides/`
- Clear ownership: `planifest-framework/` is framework-managed; `planifest-overrides/` is human-managed
- Absence is a no-op — teams that don't need overrides don't need the directory

**Negative:**
- Two directories at repo root to explain to new team members
- Agents must check two paths for every lookup — minor overhead, mitigated by graceful fallback

**Risks:**
- A future setup script change could accidentally write to `planifest-overrides/` — mitigated by explicit test in acceptance criteria

---

## Related ADRs

- ADR-001 — extends (library-standards overrides live in this directory)
- ADR-006 — extends (permanent capability skills live in this directory)
