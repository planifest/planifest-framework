---
title: "Backlog Entry: 0000067 - Consolidate getSessionId across the four telemetry hooks"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000067 - Consolidate getSessionId across the four telemetry hooks

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`getSessionId()` has 4 copies, in `planifest-framework/hooks/telemetry/context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs` and `resolve-phase.mjs`. Unlike the six helpers `0000028-req-002` extracted, these are not equivalent. They span 3 behaviour profiles across two independent axes:

| Copy | Priority chain | Session file |
|------|----------------|--------------|
| `context-pressure.mjs` | transcript path, then `input.session_id`, then `pid-${process.ppid}` | never touched |
| `emit-phase-start.mjs` | env var, `input.session_id`, transcript path, then session file | creates `{cwd}/.claude/.planifest-session` when absent |
| `emit-phase-end.mjs`, `resolve-phase.mjs` | same 4-priority order | read-only, falls back to `pid-${process.pid}` |

A single parameterised function needs two flags, and every caller passes a different combination, which buys no safety over 4 local copies while adding a shared surface where a wrong default silently changes which session id a hook reports, or starts creating a session file from a hook that never did.

## Suggested Action

Build the before-and-after table `0000028-req-002`'s acceptance criteria describe: a fixed synthetic input set (present `session_id`; present `transcript_path` only; neither present, with and without an existing session file) run across all 4 callers, proving each profile survives unchanged. The req-002 snapshot harness already covers most of those fixtures and can be extended rather than rebuilt. Only then decide whether one function is genuinely better than four.

## Why Deferred

See `0000028`'s `tech-debt.md` TD-001 and `0000028-ADR-002`, which name the exclusion explicitly: consolidating this is a behaviour change, not a refactor, and `req-002` ruled it out on that basis. Mitigation already in place: each of the 4 copies now carries a comment naming its profile and pointing at the others, so the next person to touch one knows the other three differ.
