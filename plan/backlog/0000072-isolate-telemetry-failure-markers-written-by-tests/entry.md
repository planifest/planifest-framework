---
title: "Backlog Entry: 0000072 - Nothing prevents a hook invocation from writing into the real telemetry marker directory"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000072 - Nothing prevents a hook invocation from writing into the real telemetry marker directory

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

During `0000028`'s REQ-005 verification, three durable markers were found in the repository's own `plan/.telemetry-failures/`, all reading `SyntaxError: Unexpected token 'o', "not json" is not valid JSON` with `occurrences: 9`, spanning 12:48Z to 13:10Z. The literal payload `"not json"` is a test fixture string and the window matches that feature's own development. They had to be identified as pollution and cleared by hand before the live verification could attribute any new marker unambiguously.

**Scoped accurately at P6, because the verification report's wording invites a broader conclusion than the evidence supports.** The committed suite was re-run at P6 and does not do this. Every `0000028` test isolates its workspace, and `test-0000018-req-002`, `test-0000024-req-001`, `test-0000027-req-001` (both suites) and `test-setup-telemetry.sh` were each run against an empty marker directory and each left it empty. One P3 test repair (`6d4baf3`) had already fixed a related leak, where `getFlagPath`'s dedup flag lives in the shared OS tmpdir keyed only on `session_id` plus phase, so a fixed `session_id` of `t1` collided across runs.

The residual is structural rather than a specific broken test. `recordTelemetryFailure()` derives the marker path from the process `cwd`, so any hook invoked from the repository root with a failing payload writes a real marker into the real directory. That is exactly what ad hoc probing during development does, and it is what the orchestrator and `check-telemetry-failures.mjs` then read and surface to the human on the loop as a block-or-proceed decision. There is nothing in place to tell a marker written by a person poking at a hook from one written by a genuine backend failure.

## Suggested Action

Give the marker an unambiguous provenance signal rather than trying to forbid the write. Options worth weighing at pickup: an environment variable the test harness and any manual probe set, recorded as a field in the marker and used by `check-telemetry-failures.mjs` to exclude it; or a marker field carrying the originating payload's shape so a fixture string is visibly a fixture. Add an assertion to the harness that a full suite run leaves the repository's marker directory as it found it, so a future test that does pollute fails loudly instead of being discovered by hand during a verification pass months later.

## Why Deferred

`0000028`'s `verification-report.md` records this as an incidental finding outside that feature's acceptance criteria and states it was filed for pickup rather than fixed in scope. This entry is that filing, with the claim narrowed at P6 to what re-running the suite actually demonstrates. Also recorded in `0000028`'s `recommendations.md` TD-006.
