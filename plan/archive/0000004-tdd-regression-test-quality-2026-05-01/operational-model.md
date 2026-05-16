---
title: "Operational Model - 0000004-tdd-regression-test-quality"
status: "active"
version: "0.1.0"
---
# Operational Model - 0000004-tdd-regression-test-quality

**Feature:** 0000004-tdd-regression-test-quality

---

## Runbook Triggers

| Trigger | Action |
|---------|--------|
| Regression test fails in `run-tests.sh` | Human reviews failing test. Fix root cause in framework code, or explicitly remove the test from regression pack if obsolete (edit manifest + delete file). Do NOT suppress the test. |
| `promote-to-regression.sh` exits non-zero | Check: source test file exists, `regression-manifest.json` is valid JSON, write permissions on `tests/regression/`. Re-run after resolving. |
| TDD sub-loop escalates after 3 attempts | Human reviews the failing test and implementation. Options: fix the test assumptions, fix the implementation approach, or mark the requirement as needing redesign before proceeding. |
| Test report missing from `plan/changelog/` after P7 | Ship-agent did not complete Step T. Check ship-agent output for errors. Re-run Step T manually using the test-report template. |

---

## On-Call Expectations

Not applicable — this is offline local framework tooling. No production service, no paging.

---

## Alerting Thresholds

Not applicable — no metrics infrastructure. The regression test suite exit code is the primary health signal; it is surfaced by `run-tests.sh` final summary output.

---

## Observability

| Signal | How to read it |
|--------|---------------|
| `run-tests.sh` exit code | 0 = all suites (including regression) passed. Non-zero = at least one failure. |
| `run-tests.sh` final summary line | Reports regression pass/fail counts separately. Scan for `Regression:` label. |
| `regression-manifest.json` | Inspect to understand regression pack provenance: which features contributed tests, when they were promoted. |
| `plan/changelog/{feature-id}-test-report-*.md` | Per-feature record of test health at ship time. Primary artefact for reviewers. |

---

## Maintenance

- Regression pack growth: no hard limit on pack size, but tests should only be promoted if they cover behaviour that is core to the framework and likely to break under change. Quality over quantity.
- Manifest integrity: if a test file is manually deleted from `tests/regression/`, its manifest entry MUST also be removed. The manifest is the source of truth.
