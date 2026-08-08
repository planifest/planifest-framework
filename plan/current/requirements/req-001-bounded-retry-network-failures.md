---
title: "Requirement: req-001 - Bounded retry on network-level emission failures"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-001 - Bounded retry on network-level emission failures

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source:** US-001
**Priority:** must-have

## User Story

As a human on the loop, I want telemetry hooks to retry a network-level failure before recording it, so that a routine backend restart does not interrupt me with a failure that already self-corrected.

## Functional Requirements

- `context-pressure.mjs`, `emit-phase-start.mjs`, and `emit-phase-end.mjs` (the three hooks in `planifest-framework/hooks/telemetry/` that issue a direct `fetch` call, confirmed by grep) retry an emission that fails at the network level up to 2 times (3 attempts total), with fixed 300ms gaps between attempts, before falling back to the existing failure-marker path.
- A network-level failure is a rejected `fetch` promise (for example a `TypeError` from `ECONNREFUSED`), never an HTTP error status. The hooks already set a synthetic `err.name` of `http_<status>` on a non-ok response; the check `!err.name.startsWith("http_")` identifies a network-level failure and is the sole retry trigger.
- Each attempt keeps the existing 3s per-attempt `AbortController` timeout unchanged. The retry budget adds at most 600ms worst case (2 gaps of 300ms) on top of that, per hook invocation.
- On retry exhaustion, or on an HTTP error status at any point, the existing `recordTelemetryFailure()` durable-marker path fires exactly as it does today, with no change to the marker's shape or location.
- `resolve-phase.mjs` contains no `fetch` call of its own (confirmed by inspection). It re-execs `emit-phase-start.mjs` or `emit-phase-end.mjs` as a child process via `spawn()`, forwarding the original stdin payload unchanged. It inherits the retry behaviour transitively once those two targets are patched; no retry code is added to `resolve-phase.mjs` itself.
- `emit-event-receipt.mjs` contains no `fetch` call at all (confirmed by inspection). It only writes a local receipt file after an already-completed MCP tool call; it performs no network emission of its own. This requirement makes no code change to that file.
- Every path continues to exit 0 (NFR-001, unchanged) and introduces no queue, buffer, or local fallback (NFR-002, unchanged). A backend that is genuinely down still produces exactly one durable marker per distinct root cause.

## Acceptance Criteria

- [ ] `context-pressure.mjs`, `emit-phase-start.mjs`, and `emit-phase-end.mjs` each retry up to 2 times (3 attempts total, fixed 300ms gaps) on a network-level `fetch` failure, and never retry on an HTTP error status.
- [ ] Spawning any of the three hooks above as a child process against a backend that never listens produces exactly one durable marker under `plan/.telemetry-failures/`, and the hook exits 0.
- [ ] Spawning the same hook against a backend whose listener starts partway through the retry window (for example bound around 350ms in) delivers the event to the backend and writes no marker.
- [ ] A backend that answers with a 4xx or 5xx status on the first attempt is never retried: exactly one attempt is made, and the durable marker records the `http_<status>` error type.
- [ ] `resolve-phase.mjs`, invoked in `start` or `end` mode against a backend that never listens, still results in exactly one durable marker (written by the delegated `emit-phase-start.mjs` / `emit-phase-end.mjs` child), and `resolve-phase.mjs` itself exits 0.
- [ ] Total added worst-case latency for each of the three direct-emission hooks stays at or under 600ms above the existing 3s per-attempt abort budget.
- [ ] `emit-event-receipt.mjs` is unchanged by this requirement; its absence of a `fetch` call is confirmed by inspection, not assumed.

## Dependencies

- The shared emit-and-record extraction (US-002 / req-002 of this same feature) is the natural home for this retry loop, so the fix is written once and used by all three direct-emission hooks rather than duplicated a third time. This requirement can land before or alongside that extraction, but if the extraction lands first, the retry logic belongs in the shared module rather than being re-duplicated per hook.
- The verified diff in backlog `0000063` (`context-pressure.mjs`) is the starting implementation, including its verification approach: spawn the hook as a child process against a controllable backend, once with no listener at all and once with a listener bound partway through the retry window.
- Scope correction: `plan/current/design.md` and `plan/current/feature-brief.md` both describe the defect as spanning "all five telemetry hooks." Direct inspection (grep for `fetch` across `planifest-framework/hooks/telemetry/*.mjs`) confirms only three hooks issue a `fetch` call: `context-pressure.mjs`, `emit-phase-start.mjs`, `emit-phase-end.mjs`. `resolve-phase.mjs` has no `fetch` call of its own; it delegates via child-process spawn to the two patched hooks and inherits the fix transitively. `emit-event-receipt.mjs` has no `fetch` call at all; it has no network operation to retry. The acceptance criteria above verify transitive coverage for `resolve-phase.mjs` and confirm inapplicability for `emit-event-receipt.mjs` rather than asserting a code change in either. This should be corrected in `design.md` and `feature-brief.md` at the next update.
