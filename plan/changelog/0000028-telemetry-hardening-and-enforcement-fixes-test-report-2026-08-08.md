# Test Report (0000028-telemetry-hardening-and-enforcement-fixes, 2026-08-08)

**Feature:** Telemetry hardening and enforcement fixes
**Plan date:** 2026-08-08

## 1. Tests Run This Plan (P4 Results)

Every functional requirement appears here.

| Test file | Requirement ID(s) | Status |
|-----------|-------------------|--------|
| `test-0000028-req-001-bounded-retry-network-failures.sh` | req-001 | pass |
| `test-0000028-req-002-shared-module-extraction.sh` | req-002 | pass |
| `test-0000028-req-003-stderr-fallback-marker-write-failure.sh` | req-003 | pass |
| `test-0000028-req-004-install-refresh-registration.sh` | req-004, plus P5 SEC-001 wiring regression | pass |
| (verification by execution, not a suite) | req-005 | pass, see below |
| `test-0000028-req-006-em-dash-guard.sh` | req-006 | pass |

**Summary:** 56 feature suites and 22 regression tests run. 78 passed, 0 failed, 0 skipped.

**req-005 carries no automated test, deliberately.** It asserts a live hook firing, which no test can
reproduce without a real host tool session. That is precisely why backlog `0000058` existed: the assumption
had only ever been checked by invoking the script directly. Its evidence is the observed live run recorded
in `verification-report.md`, where a real `Skill` call fired `PreToolUse(Skill)`, `resolve-phase.mjs`
resolved the phase correctly, and `phase_start (1)` was confirmed at the backend for this session's genuine
id. Recording that as a suite pass would misrepresent how it was verified.

Three pre-existing or superseded tests were repaired during this run rather than bypassed:

| Test file | Why it needed repair |
|-----------|----------------------|
| `test-0000027-req-003-005-007-008-governance-docs.sh` | Asserted an ADR path under `plan/current/adr/`, which only ever holds the in-flight feature's artifacts. That ADR belongs to `0000027` and was archived at its own P7, so the assertion could only pass during `0000027`'s run and had been red since. Now accepts either location. |
| `test-0000018-req-002-hook-failure-marker.sh` (live and regression copies) | Asserted total silence when a marker write itself fails. req-003 deliberately ends that silence with a stderr fallback, so the expectation was superseded by design, not broken by accident. Both copies updated to assert exactly one line naming the hook. |
| `test-0000028-req-002-shared-module-extraction.sh` | Used a fixed session id against a dedup flag that lives in the shared OS tmpdir keyed only on session id and phase, so a leftover flag from a prior run short-circuited emission. Given a run-unique id, matching the pattern the `0000018` suite already used for the same reason. |

## 2. Regression Pack State

**Total promoted tests:** 22
**Passed:** 22
**Failed:** 0

The regression pack is a snapshot copy, so `test-0000018-req-002-hook-failure-marker.sh` existed in both
`tests/` and `tests/regression/`. Updating only the live copy left the pack red, which is exactly what the
pack is for. Both copies were updated together, with the reason recorded inline in each.

No regression failures required triage before archiving.

## 3. Newly Promoted Tests (This Feature)

| Test file | Promoted by | Decision rationale |
|-----------|-------------|-------------------|
| (none) | n/a | No test file carried a `# REGRESSION-CANDIDATE:` tag, so nothing was presented for promotion. |

Worth noting for a future run: `test-0000028-req-004-install-refresh-registration.sh` is a plausible
candidate, since it guards SEC-001, a defect that silently disabled most of the framework's enforcement
layer and that the existing suite structurally could not catch. It was not tagged during P3, so it is not
promoted here rather than promoted without the tag the process expects.

## 4. Summary

**Overall test health:** Healthy. 78 of 78 passing, no failures, no skips.
