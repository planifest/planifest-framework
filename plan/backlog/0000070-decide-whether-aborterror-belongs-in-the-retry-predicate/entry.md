---
title: "Backlog Entry: 0000070 - Decide whether AbortError belongs in the telemetry retry predicate"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000070 - Decide whether AbortError belongs in the telemetry retry predicate

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`planifest-framework/hooks/telemetry/emit-event.mjs` retries on `!(err?.name ?? "").startsWith("http_")`. That correctly excludes HTTP error statuses per `0000028-ADR-001`, but it also admits `AbortError`.

An abort means the 3s timer fired, which is the signature of a backend that received the POST and answered slowly, not of a listener gap. Retrying re-sends an event the listener may already hold, up to 3 times. The design rationale recorded in `emit-event.mjs` reasons only about `ECONNREFUSED` and does not address the abort case, so the current behaviour is incidental rather than decided.

Raised as SEC-004 (Low) in `0000028`'s security report, which asks for the decision to be made deliberately.

## Suggested Action

Either exclude `AbortError` from the retry predicate, or add an explicit event id to the envelope so deduplication becomes a contract rather than the listener's choice. Today the envelope is byte-identical across attempts, because `timestamp` is fixed before the first attempt in all 3 callers, so `(session_id, phase, event, timestamp)` works as a natural dedup key, but nothing obliges a listener to use it.

## Why Deferred

See `0000028`'s `recommendations.md` REC-002 and TD-004. Accepting the current behaviour is defensible, so this was not treated as a P5 blocker, but telemetry is the governance audit trail and duplicates there are a records-integrity matter rather than noise. The decision wants making explicitly, in either direction.
