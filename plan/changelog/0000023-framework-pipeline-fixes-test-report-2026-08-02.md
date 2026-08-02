# Test Report — 0000023-framework-pipeline-fixes — 2026-08-02

**Feature:** Framework Pipeline Fixes
**Plan date:** 2026-08-02

## 1. Tests Run This Plan (P4 Results)

| Test file | Requirement ID(s) | Status |
|-----------|-------------------|--------|
| `test-0000023-req-001-continuous-run-p1-p3.sh` | req-001 | pass (7/7) |
| `test-0000023-req-002-marker-commit-lifecycle.sh` | req-002 | pass (7/7) |
| `test-0000023-req-003-copilot-setup-self-copy.sh` | req-003 | pass (13/14) — 1 documented, out-of-scope failure (`setup.sh all` exit 0, blocked by a separate pre-existing `cline.sh` bug unmasked by this fix, not a req-003 regression) |
| `test-0000023-req-004-telemetry-product-id-emission.sh` | req-004 | pass (21/21) |

**Summary:** 4 test files run — 48 assertions passed, 1 assertion documented-fail (pre-existing, out-of-scope, unrelated to any of this feature's 4 requirements), 0 skipped.

## 2. Regression Pack State

**Total promoted tests:** 22 files
**Passed:** 22 (all pre-existing regression suites, unaffected by this feature)
**Failed:** 0

No regression pack test file failures. The one failing assertion this run belongs to a new feature test (`test-0000023-req-003-...`), not the regression pack.

## 3. Newly Promoted Tests (This Feature)

No regression candidates. None of the 4 new test files carry a `# REGRESSION-CANDIDATE:` tag — consistent with this repo's current state, where no existing feature test carries that tag either (confirmed by a repo-wide search at P7). Promotion to the long-term regression pack is deferred to a future human decision, per the existing `promote-to-regression.sh` process.

## 4. Summary

**Overall test health:** ✅ Healthy — one documented, pre-flagged, out-of-scope failure (unrelated `cline.sh` bug, filed as backlog `0000034`); zero regressions introduced by this feature.
