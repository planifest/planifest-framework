# Test Report — 0000027-backlog-batch-governance-tooling-fixes — 2026-08-08

**Feature:** Backlog batch: governance and tooling fixes
**Plan date:** 2026-08-08

## 1. Tests Run This Plan (P4 Results)

| Test file | Requirement ID(s) | Status |
|-----------|-------------------|--------|
| test-0000027-req-001-telemetry-hooks-wired.sh | req-001 | pass |
| test-0000027-req-001-resolve-phase-resolver.sh | req-001 | pass |
| test-0000027-req-002-cline-path-collision.sh | req-002 | pass |
| test-0000027-req-003-005-007-008-governance-docs.sh | req-003, req-005, req-007, req-008 | pass |
| test-0000027-req-004-telemetry-compliance-backstop.sh | req-004 | pass |

req-006 (historical backlog backfill) has no dedicated automated test — verified directly during P3 by its implementing subagent via `git diff --stat`/`git status --porcelain` against `plan/_archive/` confirming zero source-file modification, and by re-reading all 4 source `recommendations.md` files to confirm the 7 filed rows match exactly. No runtime behaviour exists to assert beyond file presence, confirmed manually.

**Summary:** 5 new test files, 51 feature suites overall (up from 50 pre-feature) — all passing, 0 failed, 0 skipped.

## 2. Regression Pack State

**Total promoted tests:** 22
**Passed:** 22
**Failed:** 0

| Test file | Source feature | Promoted by | Promotion date | Status |
|-----------|---------------|-------------|----------------|--------|
| test-0000005-framework-governance.sh | 0000005 | human | (pre-dates promotion tracking) | pass |
| test-0000006-build-assessment.sh | 0000006 | human | (pre-dates promotion tracking) | pass |
| test-0000009-rail-tightening.sh | 0000009 | human | (pre-dates promotion tracking) | pass |
| test-0000016-pipeline-governance.sh | 0000016 | human | (pre-dates promotion tracking) | pass |
| test-0000017-req-001-regression-promotion.sh | 0000017 | human | (pre-dates promotion tracking) | pass |
| test-0000017-req-002-ratchet-approve.sh | 0000017 | human | (pre-dates promotion tracking) | pass |
| test-0000017-req-004-cross-platform-hooks.sh | 0000017 | human | (pre-dates promotion tracking) | pass |
| test-0000017-req-005-scope-lock-suggested-answers.sh | 0000017 | human | (pre-dates promotion tracking) | pass |
| test-0000017-req-006-structured-discovery-pass.sh | 0000017 | human | (pre-dates promotion tracking) | pass |
| test-0000017-req-007-change-agent-archive.sh | 0000017 | human | (pre-dates promotion tracking) | pass |
| test-0000018-req-001-remove-context-mode-mcp-coupling.sh | 0000018 | human | (pre-dates promotion tracking) | pass |
| test-0000018-req-002-hook-failure-marker.sh | 0000018 | human | (pre-dates promotion tracking) | pass |
| test-0000018-req-003-orchestrator-marker-check-and-prompt.sh | 0000018 | human | (pre-dates promotion tracking) | pass |
| test-0000018-req-004-phase-skill-telemetry-rewrite.sh | 0000018 | human | (pre-dates promotion tracking) | pass |
| test-0000018-req-005-build-log-telemetry-record.sh | 0000018 | human | (pre-dates promotion tracking) | pass |
| test-0000018-req-006-telemetry-standards-update.sh | 0000018 | human | (pre-dates promotion tracking) | pass |
| test-0000018-req-007-discovery-md-hard-limit.sh | 0000018 | human | (pre-dates promotion tracking) | pass |
| test-0000019-req-002-component-yml-matcher.sh | 0000019 | human | (pre-dates promotion tracking) | pass |
| test-commit-msg-hook.sh | (pre-existing) | human | (pre-dates promotion tracking) | pass |
| test-gate-write-windows.sh | (pre-existing) | human | (pre-dates promotion tracking) | pass |
| test-regression-pack.sh | (pre-existing) | human | (pre-dates promotion tracking) | pass |
| test-skill-telemetry.sh | (pre-existing) | human | (pre-dates promotion tracking) | pass |

No regression failures.

## 3. Newly Promoted Tests (This Feature)

None — no `# REGRESSION-CANDIDATE:` tags were present in any P3/P4 test file this run, so no promotion candidates were surfaced to the human at Step 4.

## 4. Summary

**Overall test health:** ✅ Healthy — 75 skill-telemetry assertions, 51 feature suites, and 22 regression suites all pass; self-description check passes; both P5 security findings closed with regression tests locking in the fixes.
