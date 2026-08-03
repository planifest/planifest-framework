# Test Report — 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes — 2026-08-03

**Feature:** Pipeline gate and config fixes, and ship-agent fixes
**Plan date:** 2026-08-03

## 1. Tests Run This Plan (P4 Results)

| Test file | Requirement ID(s) | Status |
|-----------|-------------------|--------|
| test-0000025-req-001-ship-agent-pr-footer.sh | req-001 | pass (15/15) |
| test-0000025-req-002-ship-agent-p7-git-add.sh | req-002 | pass (10/10) |
| test-0000025-req-003-subagent-parallelism-expansion.sh | req-003 | pass (16/16) |
| test-0000025-req-003-docs-agent-parallelism.sh | req-003 | pass (9/9) |
| test-0000025-req-004-setup-config-relocation.sh | req-004 | pass (29/29) |
| test-0000025-req-005-backlog-unification.sh | req-005 | pass (15/15) |
| test-0000025-req-006-docs-agent-continuous-run.sh | req-006 | pass (11/11) |
| test-0000025-req-007-scope-lock-default-batch.sh | req-007 | pass (21/21) |

**Summary:** 8 test files run — 8 passed, 0 failed, 0 skipped (126 total assertions).

All 7 functional requirements from `plan/current/requirements/` are represented above (req-003 is split across two files since it touches two independent target files).

## 2. Regression Pack State

**Total promoted tests:** 22
**Passed:** 22
**Failed:** 0

Full pack re-run at P7: 22/22 pass. One pre-existing regression-pack test (`test-0000017-req-005-scope-lock-suggested-answers.sh`) initially failed for the same reason its non-regression counterpart did — section (a) asserted the exact opt-in-per-question default this feature's req-007 intentionally superseded. Fixed with the identical targeted update applied to both copies (see below); not a new regression, an expected consequence of shipping req-007.

Full (non-regression) suite: 45 test files, 43 pass. The 2 non-regression-pack failures are independently confirmed pre-existing and unrelated to this feature (not fixed here, out of scope): `test-0000010-framework-quality-improvements.sh` (fails identically against `main`, confirmed via direct comparison) and `test-0000023-req-003-copilot-setup-self-copy.sh` (documented pre-existing cline.sh bug, backlog 0000034, self-reported as such in its own failure message).

| Test file | Source feature | Promoted by | Promotion date | Status |
|-----------|---------------|-------------|----------------|--------|
| test-0000017-req-005-scope-lock-suggested-answers.sh | 0000017 | (pre-existing, promotion date not recorded in this run) | — | pass (updated for req-007) |
| (21 other pre-existing regression-pack tests, unaffected by this feature) | various | — | — | pass |

## 3. Newly Promoted Tests (This Feature)

None. No test files produced by this feature were tagged `# REGRESSION-CANDIDATE:` (confirmed via grep at P7 Step 4) — all 8 new tests are feature-scoped content-assertion tests for `planifest-framework` skill/script files, not candidates for the cross-feature regression pack at this time.

## 4. Summary

**Overall test health:** ✅ Healthy — 8/8 new test files pass (126/126 assertions), 22/22 regression pack tests pass, 43/45 full suite (2 confirmed pre-existing, unrelated failures), 2 pre-existing tests updated for intentional supersession (both copies of test-0000017-req-005, tests/ and tests/regression/), zero new regressions introduced.
