---
title: "ADR-004: Repo instructions loaded into design.md at P0"
status: "accepted"
version: "0.1.0"
---
# ADR-004 - Repo instructions loaded into design.md at P0

**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000005-framework-governance
**Status:** accepted
**Date:** 02 May 2026

---

## Context

Humans need a way to declare repo-specific constraints that all agents must follow — for example, "no git push or pull; local operations only". These instructions must reach every agent in every phase without the human repeating them. Two viable propagation mechanisms exist: inject on every turn via the `check-design.mjs` hook, or write to `design.md` once at P0 so all agents read them as part of their normal phase-start context load.

---

## Decision

The orchestrator reads all `.md` files in `planifest-overrides/instructions/` at P0 start and writes their content to `plan/current/design.md` under a `## Repo Instructions` section. All agents read `## Repo Instructions` from design.md at phase start and treat each instruction as a hard constraint. If the directory is absent or empty, the section reads "None".

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Inject via `check-design.mjs` on every UserPromptSubmit | Instructions present on every turn; no risk of agents missing them | Injects on every turn regardless of phase or relevance; adds to every prompt; hook must read files on every invocation | Per-turn injection is wasteful and adds hook latency; design.md is already the shared state agents read |
| Embed instructions directly in CLAUDE.md / tool config | Picked up automatically by the tool | Tool-specific; not portable across tools; conflicts with framework instructions rather than extending them | Must work across all supported tools; `planifest-overrides/` is the tool-agnostic override mechanism |
| Pass as environment variables | Simple for CI/CD | Not readable by agents as natural language; requires shell-level config per instruction | Agents reason over Markdown, not env vars |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator | Reads `planifest-overrides/instructions/` at P0; writes `## Repo Instructions` to design.md |
| All phase agents | Read `## Repo Instructions` from design.md at phase start; apply as hard constraints |
| check-design.mjs | No change required for instructions propagation |

---

## Consequences

**Positive:**
- Instructions written once, available to all agents for the entire pipeline run via the existing design.md read
- No per-turn overhead — hook is not involved in instruction propagation
- Human-readable and auditable — instructions are visible in design.md

**Negative:**
- Instructions are only refreshed at P0 — a human who adds an instruction mid-pipeline must restart from P0 for it to take effect
- Agents must actively read design.md at phase start — if a phase agent skips this, instructions are not applied

**Risks:**
- An instruction file with ambiguous scope (e.g. "be careful with git") may be interpreted inconsistently by different agents — mitigated by documenting that instructions must be specific and actionable

---

## Related ADRs

- ADR-003 — related-to (both use design.md as shared session state written at P0)
- ADR-002 — depends-on (instructions live in planifest-overrides/)
