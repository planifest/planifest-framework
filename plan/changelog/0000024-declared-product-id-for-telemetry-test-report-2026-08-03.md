# Test Report — 0000024-declared-product-id-for-telemetry — 2026-08-03

**Feature:** Declared product_id and telemetry envelope fix
**Plan date:** 2026-08-03

## 1. Tests Run This Plan (P4 Results)

| Test file | Requirement ID(s) | Status |
|-----------|-------------------|--------|
| `test-0000024-req-001-declared-product-id.sh` (new) | req-001 | pass (42/42) |
| req-002 (no dedicated test file — documentation fix + 8-skill audit, verified by content review; live re-verification via a real `adr_decision` event emitted during P2, confirmed via `query_telemetry`, id `c8d820f5-26f8-4a36-b4e6-3be1020664fc`) | req-002 | pass (verified by content review + live emission, not an executable test) |

**Summary:** 42 tests run in the new file — 42 passed, 0 failed, 0 skipped. req-002 verified by non-test means as documented above.

## 2. Regression Pack State

**Total promoted tests:** 22 (unchanged — no new promotions this feature; see Section 3)
**Passed:** 22
**Failed:** 0

Full suite (`planifest-framework/tests/run-tests.sh`): 36 feature suites passed / 1 failed (pre-existing, unrelated — `test-0000023-req-003-copilot-setup-self-copy.sh` case (e), tracked as backlog 0000034, a cline.sh path-collision bug that predates this feature), 22 regression suites passed / 0 failed.

Three pre-existing tests required adjustment (not new tests, not regression promotions — existing coverage adapted to the behaviour change): `test-0000018-req-002-hook-failure-marker.sh` and its `regression/` copy, and `test-context-pressure.sh` — each needed a `product.yml` added to their scratch test directories, since the hooks under test now require a declared `product.yml` `id` rather than tolerating any `cwd` via the git-path fallback. All three pass after adjustment.

One test was deleted, not adjusted: `test-0000023-req-004-telemetry-product-id-emission.sh` — its assertions tested the git-path `product_id` behaviour this feature removes entirely; req-001 explicitly named it obsolete and superseded by the new test file.

### Regression Failures

None.

## 3. Newly Promoted Tests (This Feature)

No regression candidates tagged (`# REGRESSION-CANDIDATE:` scan of P3/P4 test files returned zero matches) — none promoted this feature.

## 4. Summary

**Overall test health:** ✅ Healthy — 42/42 new assertions pass, 22/22 regression pack passes, 36/37 feature suites pass (the 1 failure is pre-existing, unrelated, and independently tracked).
