---
title: "Backlog Entry: 0000072 - Isolate telemetry failure markers written by the test suite"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000072 - Isolate telemetry failure markers written by the test suite

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

Telemetry tests write durable failure markers into the repository's real `plan/.telemetry-failures/` rather than an isolated scratch workspace.

Found during `0000028`'s REQ-005 verification: three markers were present before the run, all reading `SyntaxError: Unexpected token 'o', "not json" is not valid JSON` with `occurrences: 9`, spanning 12:48Z to 13:10Z. The literal payload `"not json"` is a test fixture string and the window matches that feature's own test runs. They had to be identified as pollution and cleared by hand before the live verification could attribute any new marker unambiguously.

The orchestrator, and `check-telemetry-failures.mjs`, read that directory and surface its contents to the human on the loop as a block-or-proceed decision. Test-written markers are indistinguishable from real ones at that point.

## Suggested Action

Point the marker directory at a temporary workspace for the duration of a test run, the way `0000028`'s retry tests already isolate their controllable backend. `record-telemetry-failure.mjs` derives the marker path from `cwd`, so running the hook with a scratch `cwd`, or threading an override the tests set, are both plausible shapes. Whichever is chosen, add an assertion that a test run leaves the repository's own marker directory untouched.

## Why Deferred

`0000028`'s `verification-report.md` records this as an incidental finding outside that feature's acceptance criteria and states it was filed for pickup rather than fixed in scope. This entry is that filing. Also recorded in `0000028`'s `recommendations.md` TD-006. It is a test-isolation defect, not a defect in the hooks under test.
