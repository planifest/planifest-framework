---
title: "ADR-005: Markdown migration files with interactive migrator skill"
status: "accepted"
version: "0.1.0"
---
# ADR-005 - Markdown migration files with interactive migrator skill

**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000005-framework-governance
**Status:** accepted
**Date:** 02 May 2026

---

## Context

As framework standards evolve, existing artefacts drift out of compliance — date formats, British English spellings, template structures. A mechanism is needed to detect and correct non-compliant artefacts across `plan/`, `docs/`, and `planifest-framework/`. The mechanism must be interactive (human confirms changes) and self-archiving (completed migrations do not re-run).

---

## Decision

Migrations are Markdown files in `planifest-framework/migrations/`. Each file describes what to scan for and what to correct. The `planifest-migrator` skill reads the file, executes the migration interactively (presenting each finding to the human for confirmation), and moves the file to `migrations/_done/` on completion. The orchestrator scans for pending migrations at every session start and invokes the migrator before proceeding.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Executable scripts (`.sh`/`.ps1`/`.js`) | Deterministic, automatable | Cannot present findings interactively to a human; cannot reason about context (e.g. skip code identifiers); require a shell runtime | Agents are better at context-sensitive text transformations than shell scripts; human confirmation is a requirement |
| Manual migration checklist in CHANGELOG | Simple | Relies entirely on human memory and discipline; no automated detection | The problem is silent drift — a checklist doesn't detect anything |
| Database-backed migration state (like Flyway/Liquibase) | Industry standard pattern for SQL migrations | Requires a running database; disproportionate infrastructure for file-based artefact corrections | No database in this stack; Markdown files with `_done/` archiving achieve the same ordered, idempotent semantics |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator | Scans `migrations/` at session start; invokes planifest-migrator if pending files found |
| planifest-migrator (new) | Reads migration file; executes interactively; archives to `_done/` |
| planifest-framework/migrations/ | New directory; contains pending and done migrations |

---

## Consequences

**Positive:**
- Human remains in control — every change is confirmed before application
- Self-archiving — `_done/` ensures migrations never re-run; ordering by filename prefix (e.g. `0001-`, `0002-`) is deterministic
- Extensible — any human can add a migration by dropping a `.md` file; no framework release required

**Negative:**
- Interactive migrations cannot run in fully automated CI — they require a human session
- Migration quality depends on the migrator skill's ability to correctly identify and skip non-prose content (e.g. code identifiers)

**Risks:**
- A poorly written migration file could cause the migrator to over-correct (e.g. rename code identifiers) — mitigated by requiring human confirmation per finding and by R-005 in the risk register

---

## Related ADRs

- ADR-003 — related-to (orchestrator session-start scan mirrors sentinel check pattern)
