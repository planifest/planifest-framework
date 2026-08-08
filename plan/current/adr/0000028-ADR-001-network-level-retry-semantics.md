---
title: "ADR 001: Network-level retry semantics for telemetry emission"
summary: "Retry only network-level fetch failures in the telemetry emit hooks, never HTTP error statuses, since only the former is the signature of a transient listener gap."
status: "proposed"
version: "0.1.0"
---
# ADR-001 - Network-level retry semantics for telemetry emission

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Component:** planifest-framework
**Date:** 2026-08-08

## Context

`context-pressure.mjs`, `emit-phase-start.mjs`, and `emit-phase-end.mjs` each POST an event with a single, unretried `fetch`. Two failure shapes reach the same catch block today and are treated identically:

- A network-level `fetch` rejection (`TypeError`, no listener bound). This is the signature of a listener gap, not a real failure. It is frequently transient.
- An HTTP error status (4xx/5xx). A listener answered and deliberately rejected the event. This is a real failure.

The current code cannot tell these apart because it does not try. Both paths write a durable marker under `plan/.telemetry-failures/`, which the orchestrator (and `check-telemetry-failures.mjs`, added in 0000026) surfaces as a block-or-proceed interrupt to the human on the loop.

This produced 4 spurious durable markers in this repo on 2026-08-08 between 09:10:28Z and 09:11:55Z, and 10 in the downstream repo `structured-telemetry-mcp` in the same window, all from routine `npm run deploy` restarts of the telemetry daemon. Between the old daemon exiting and the new one binding the port, there is a ~1-2s window with no listener. Any hook firing in that window sees a network-level failure, and the framework records something that was never actually wrong.

## Decision

Narrow the definition of a telemetry emission failure. Retry a network-level failure only. Never retry an HTTP error status.

The hooks already set a synthetic `err.name` of `http_<status>` on a non-ok response. The check `!err.name.startsWith("http_")` is therefore sufficient to identify a network-level failure and is the sole retry trigger.

Budget: 2 retries, 3 attempts total, fixed 300ms gaps between attempts. This sits on top of the existing 3s per-attempt `AbortController` abort, unchanged. On retry exhaustion, or on an HTTP error status at any point, `recordTelemetryFailure()` fires exactly as it does today. No change to marker shape or location.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Exponential backoff instead of fixed gaps | Reduces load on a backend that is down for longer | Adds complexity and a growing latency tail for a budget this small (2 retries); the listener-gap window this fixes is ~1-2s and fixed, not variable | Fixed 300ms gaps already fit the observed gap window with predictable worst-case latency. Backoff solves a scaling problem this hook does not have. |
| A larger retry budget | Covers a longer listener gap | Each added attempt risks another 3s abort on top of 300ms gaps; worst-case latency grows fast and the hook must stay fast (NFR-001 adjacent) | 2 retries at 300ms already covers the observed ~1-2s restart window with margin. A larger budget trades hook speed for a case that is not observed. |
| Local queue or write-ahead buffer for undelivered events | Would guarantee eventual delivery | Directly forbidden by NFR-002; this is a retry within one hook invocation, not a delivery-guarantee mechanism | NFR-002 forbids any queue, buffer, or local fallback for undelivered telemetry. Out of scope by design constraint, not by preference. |
| Health-check the backend before emitting | Could avoid firing into a known-down backend | Doubles the request count on every emission and still races the same restart window; a health check that passes can still fail by the time the real POST fires | Does not remove the race, only moves it, while paying for it on every single emission instead of only on failure. |
| Suppress markers entirely for TypeError | Removes the false-positive markers outright | A genuinely-down backend that never recovers would then produce zero signal, silently discarding failures the human on the loop needs to see | NFR-002's marker path exists so a real failure is never silent. Suppression breaks that guarantee to fix a false positive; retry does not. |
| Do nothing, have the orchestrator ignore repeated markers | No code change to the hooks | Pushes the distinction (transient vs real) into the orchestrator, which sees only the marker, not the original error; it cannot recover the network-vs-HTTP signal after the fact | The distinguishing information (`err.name`) exists only at the point of failure, inside the hook. Deferring the decision downstream discards the one signal that makes the decision possible. |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs` gain a bounded retry loop on the network-level branch only. `resolve-phase.mjs` inherits the fix transitively via child-process spawn, no code change. `emit-event-receipt.mjs` has no `fetch` call and is unaffected. |

## Consequences

**Positive:**
- A routine, self-correcting backend restart no longer interrupts the human on the loop with a block-or-proceed decision about something that was never wrong.
- A genuinely-down backend is still reported: retry exhaustion still writes the durable marker exactly as before.

**Negative:**
- Retry makes a genuinely degraded backend less visible. A backend that is slow-flapping (intermittently up just long enough to accept a retried attempt) now gets absorbed into a successful emission instead of surfacing a marker.
- Worst-case hook latency rises by ~600ms on the failure path only (2 gaps of 300ms), on top of the existing 3s per-attempt abort budget.

**Risks:**
- If a future change stops setting the synthetic `err.name` of `http_<status>` on a non-ok response, the retry check silently falls back to treating HTTP errors as network failures and retries them. Mitigation: the acceptance criteria for req-001 assert this behaviour directly against a backend that answers 4xx/5xx.

## Related ADRs

- None yet recorded for this feature.

## Supersedes

- None.

## Superseded By

- None.
