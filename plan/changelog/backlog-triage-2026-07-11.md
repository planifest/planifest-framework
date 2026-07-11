# Changelog — backlog-triage — 11 Jul 2026

**Change:** Test-harness portability fixes and doc-drift repair (Change Pipeline)
**Backlog entries closed:** 0000001, 0000003, 0000004, 0000006, 0000007
**Backlog entries left open:** 0000002, 0000005 (cross-repo), 0000008, 0000009, 0000010

## What Was Fixed

- **Test portability (0000001):** `head -n -1` (GNU-only, errors on BSD/macOS) replaced with portable `sed '$d'` in 13 places across 3 test files.
- **False-positive test failures (0000003):** two suites were asserting against stale content/buggy normalization, not real drift — `getting-started.md` assertions repointed to `pipeline-reference.md` (content moved there in the 0000012 docs restructure); a `sed` bracket-expression bug that silently deleted every "r" character was replaced with `tr -d`, revealing the true external-skill mismatch count is 0/372, not 279/372.
- **Test runner registration gap (0000004):** `run-tests.sh` now globs `test-*.sh` instead of a hardcoded 9-suite list; all 14 existing suites run on every invocation.
- **Docs drift (0000006):** `dependency-graph.md` gained the `planifest-framework` and `setup-hook-integration` nodes it was missing relative to `component-registry.md`.
- **Orphaned roadmap docs (0000007):** `0008b` closed with a status note (fully shipped, piecemeal, across unrelated features); `0008c` cross-referenced to backlog `0000005` as the live tracking entry for its still-open schema work.

## Verification

`bash planifest-framework/tests/run-tests.sh`: 7 passed / 2 failed (checking 9/14 suites) → **14 passed / 0 failed** (checking all 14 suites).

## Not Fixed

Backlog `0000005` (telemetry MCP schema gap) requires changes in the separate `structured-telemetry-mcp` repository — assessed, cross-referenced, left open; cannot be closed from this repo.
