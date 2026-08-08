---
title: "SLO Definitions - telemetry-hardening-and-enforcement-fixes"
summary: "SLIs, SLOs, and error budgets, scoped honestly to a local developer-tooling hook."
status: "draft"
version: "0.1.0"
---
# SLO Definitions - telemetry-hardening-and-enforcement-fixes

**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes

## Scope of this document

There is no deployed service behind this feature, so there is no service-level uptime, latency
percentile dashboard, or customer-facing error budget to define. The hooks are short-lived local
subprocesses invoked once per relevant tool event; each invocation either exits 0 having emitted, or
exits 0 having recorded a durable marker. The measurable targets below are hook-level and mostly
design constraints verified once in testing, not SLOs tracked continuously in production. Each entry
states plainly which kind it is.

## Targets

### 1. Added retry latency

**Statement:** retry must not add more than 600ms worst case on top of the existing 3s per-attempt
abort, per hook invocation.

**Kind:** design constraint (NFR in `feature-brief.md`), verified once by timed test against a backend
that never listens. Not a continuously measured SLO - there is no telemetry pipeline monitoring hook
wall-clock time in the field.

**Basis:** 2 retry attempts at a 300ms budget each, inherited from the downstream `0000063` fix
(flagged as an assumption needing re-derivation in `risk-register.md` A-003). Only reached on the
failure path; a first-attempt success pays no added latency at all.

### 2. Hooks exit 0 on 100 percent of paths

**Statement:** every one of the five telemetry hooks exits 0 on every code path, including retry
exhaustion, marker-write failure, and any unexpected error.

**Kind:** hard constraint, not a percentile SLO. This is binary per hook per path: either it holds
under test (existing NFR-001, asserted by test) or it does not, in which case req-001/req-002 have a
defect (see `risk-register.md` R-001) and the change does not ship. There is no acceptable non-zero
exit rate to budget against; a single non-zero exit on the host session's hook path is a session-safety
regression, not a budget-tracked event.

### 3. False-positive marker rate for the daemon-restart case

**Statement:** a backend that starts listening partway through the retry window must deliver the event
and produce no marker, on every occurrence.

**Kind:** design target, verified by test (existing NFR in `feature-brief.md`: "listener bound partway
through the retry window"). Framed as a rate here only because "should go to zero" is the honest way
to state it: before this feature the rate was effectively 100 percent (any network failure produced a
marker, including a restart that resolved within the same second); after this feature it should be 0
percent for restarts that resolve within the 2-attempt/300ms window. A restart that takes longer than
the retry budget legitimately still produces a marker - see target 4.

### 4. Exactly one marker for a genuinely-down backend

**Statement:** a backend that never listens throughout must still produce exactly one durable marker,
and the hook must still exit 0.

**Kind:** design target, verified by test (existing NFR in `feature-brief.md`: "no listener present
throughout"). "Exactly one" matters in both directions: zero markers would mean a real failure went
unrecorded (silent no-op, the R-001 failure mode); more than one uncoalesced marker per distinct
`root_cause_key` would make `check-telemetry-failures.mjs`'s injected reminder noisy and would not
match the existing occurrence-counting marker shape (first-seen/last-seen timestamps, incrementing
`occurrences` on repeat, per `design.md`'s cross-session continuity scenario).

## Error budget

Not applicable in the conventional sense - there is no traffic volume to compute a budget against, and
no rolling window of production requests. The closest equivalent is target 2 above (100 percent exit-0
compliance), which has zero tolerance by design rather than a numeric budget. If the human on the loop
wants a budget-style framing: the "budget" is the single stderr line added by req-003 for a
marker-write failure - that is the one path this feature accepts as a visible-but-non-blocking
degradation, and it exists precisely so that a truly silent failure (the thing target 4 exists to
prevent) never has zero signal even in that edge case.
