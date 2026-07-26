# Change Summary

Change request: Pick up backlog entries 0000001, 0000003, 0000004, 0000006, 0000007 — clean up the test harness and repair docs drift discovered during 0000016's post-ship review. (0000005 also assessed: cross-repo, not actionable here — left open.)
Interpretation: Fix each backlog item at its actual root cause rather than its symptom; verify with the real test suite before closing any entry.
Components affected: planifest-framework (tests/, docs/, README.md)
Contract changed: no
Schema changed: no
Migration proposed: no
Consumers affected: none
Blast radius: planifest-framework/tests/*.sh (3 files fixed for portability, 2 files fixed for false-positive assertions), planifest-framework/tests/run-tests.sh (registration mechanism), docs/dependency-graph.md, docs/0008b, docs/0008c

---

## What actually happened, per entry

- **0000001** (SIGPIPE/`head -n -1` under pipefail): confirmed and fixed. `head -n -1` is GNU-only; BSD/macOS `head` errors on a negative count, producing empty captured output and (via the resulting broken pipe) corrupted exit-code capture. Replaced all 13 occurrences across `test-regression-pack.sh`, `test-commit-msg-hook.sh`, `test-skill-sync-security.sh` with the portable `sed '$d'`.
- **0000003** (stale test suites): **neither failure was real drift.** (a) `test-0000009-rail-tightening.sh` asserted content in `getting-started.md` that was deliberately relocated to `pipeline-reference.md` during the 0000012 three-file docs restructure — repointed the assertions, content was never lost. (b) `test-0000010-...` REQ-003 reported "279/372 skill directories mismatched" — the test's own `sed 's/["\r]//g'` silently deleted every literal `r` character (BSD sed doesn't treat `\r` inside `[...]` as a carriage-return escape), so it was comparing corrupted strings against real ones. Fixed with `tr -d '"\r'`; re-verified independently in JS — actual mismatch count is 0/372.
- **0000004** (`run-tests.sh` registration gap): replaced the 9-line hardcoded `run_suite` list with a glob over `test-*.sh`. All 14 existing suites now run automatically; no future suite can be silently skipped.
- **0000006** (dependency-graph missing node): added `planifest-framework` and `setup-hook-integration` as first-class subgraphs with their real relationships (setup.sh distributes the framework's hooks/skills/templates; ratchet-check.mjs/gate-write.mjs wiring to the PreToolUse runner).
- **0000007** (orphaned roadmap docs): `0008b` (telemetry framework wiring) turned out to be **fully shipped already**, piecemeal, across several unrelated features — closed with a status note pointing at the real source of truth (`telemetry-standards.md`). `0008c` (MCP server schema gaps) is still genuinely open and cross-repo — cross-referenced to backlog `0000005`, which is now the tracking entry.
- **0000005** (telemetry schema, cross-repo): assessed only, not fixed — requires changes in the separate `structured-telemetry-mcp` repo. Left open in `plan/backlog/`.

## Verification

`bash planifest-framework/tests/run-tests.sh` — before: 7 passed, 2 failed (and silently only checking 9 of 14 suites). After: **14 passed, 0 failed**, all 14 suites actually running.

## Also in this session (separate branch, not part of this change)

`README.md`'s Rationale section was reworded on `fix/readme-agile-framing` (not this branch) to frame Planifest as adapting agile's judgment call to a new bottleneck, rather than agile being superseded — per explicit human request, unrelated to the backlog triage.
