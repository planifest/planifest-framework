---
title: "ADR-003: Sentinel file for orchestrator enforcement"
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Sentinel file for orchestrator enforcement

**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000005-framework-governance
**Status:** accepted
**Date:** 02 May 2026

---

## Context

Nothing currently prevents an agent from writing to `plan/current/` without loading the orchestrator skill. As demonstrated on 02 May 2026, an agent can produce plan artefacts directly, bypassing P0 coaching and the confirmed design gate. A hard enforcement mechanism is needed that works within the existing hook infrastructure.

---

## Decision

The orchestrator writes a sentinel file `plan/.orchestrator-active` containing the current feature-id at P0 start. `gate-write.mjs` checks for this file before allowing any write to `plan/current/**` (except `plan/current/feature-brief.md`). Exit 2 if absent. The ship-agent deletes it at P7. Stale sentinel (feature-id mismatch) also blocks with a warning.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Check for `plan/current/design.md` existence (existing gate-write behaviour) | Already implemented | design.md is written by the orchestrator during P0 — an agent could write a minimal design.md to unblock itself | Does not prove the orchestrator was loaded, only that the file exists |
| Git hook (pre-commit) | Runs at commit time, not write time | Too late — the damage is done by commit time; doesn't prevent mid-session drift | Enforcement must be at write time |
| Require human to manually create the sentinel | Zero agent complexity | Human friction defeats the purpose | Should be automatic and invisible when the orchestrator is loaded correctly |
| Registry/database entry | Richer metadata | Requires a running process or persistent store; overkill for a session-scoped signal | File-based is consistent with the existing hook infrastructure |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator | Writes `plan/.orchestrator-active` at P0 start |
| gate-write.mjs | Extended with sentinel existence check for `plan/current/**` writes |
| check-design.mjs | Extended to inject hard STOP when neither feature-brief nor sentinel exists |
| planifest-ship-agent | Deletes `plan/.orchestrator-active` at P7 |

---

## Consequences

**Positive:**
- Hard gate — agents cannot write plan artefacts without the orchestrator having been loaded
- Lightweight — a single `fs.existsSync` call per Write/Edit; < 5ms overhead
- Self-clearing — ship-agent deletes it, so no manual cleanup between runs

**Negative:**
- Stale sentinel after a failed P7 or clean checkout will block the next session until cleared manually
- feature-brief.md must be explicitly exempted — any path-matching error could prevent P0 from starting

**Risks:**
- Clean git checkout loses `plan/.orchestrator-active` (it should not be committed) — next session P0 start recreates it; only a problem if an agent tries to resume mid-run without re-running P0

---

## Related ADRs

- ADR-004 — related-to (both extend the design.md shared state model)
</content>
