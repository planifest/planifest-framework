---
title: "Regression Baseline - 0000021-framework-context-bloat-audit"
summary: "Recorded pass/fail state and self-correction count before any audit or trim work begins (req-001)."
status: "active"
version: "0.1.0"
---
# Regression Baseline - 0000021-framework-context-bloat-audit

**Recorded:** 2026-08-01T07:45:00Z
**Feature:** 0000021-framework-context-bloat-audit
**Requirement:** req-001

---

## Result

```
Feature suites:    33 passed, 0 failed.
Regression suite:  22 passed, 0 failed.
Results: 75 passed, 0 failed (skill-telemetry.sh sub-suite)
Overall: All tests passed. Exit code 0.
```

Full log: `/tmp/baseline-run4.log` (ephemeral — this file is the durable record).

## Regression Pack Composition

22 tests in `planifest-framework/tests/regression/` (1 pre-existing + 21 promoted this run). See `planifest-framework/tests/regression/regression-manifest.json` for the full promotion record (name, source feature, promotion date, promoted by).

## Self-Correction / Escalation Count (this pipeline run, up to this point)

0 formal `self_correction` telemetry events. Qualitative note: populating this baseline required 2 iterations to fix a pre-existing defect in `planifest-framework/scripts/promote-to-regression.sh` (discovered during this requirement — see build-log P3 notes and the script's own updated header comment). That was a root-cause infrastructure fix required to make promotion work at all, not a self-correction caused by trimming — req-004's comparison should treat trim-caused self-corrections as the signal to watch, not this prerequisite fix.

## Known Pre-Existing Quirk Fixed En Route

`promote-to-regression.sh` did a plain `cp` with no adjustment for the extra directory level `tests/regression/` sits at relative to `tests/`. Every promoted test computing a `$SCRIPT_DIR`-relative path silently broke (20 of 21 newly-promoted tests failed on first baseline attempt; the sole pre-existing entry, `test-0000016`, only worked because it had been hand-patched at promotion time in an earlier feature — a workaround never fixed at the tool level). Fixed by adding an automatic path-rewrite step to `promote-to-regression.sh` for the two common patterns, plus two bespoke manual fixes for tests with self-referential path logic (`test-regression-pack.sh`, `test-gate-write-windows.sh`/`.mjs`) that the generic rule couldn't cover. See commit history for this requirement.

## Comparison Point for req-004

req-004 re-runs this same suite after all trims and compares: pass/fail delta (expect zero new failures) and self-correction/escalation count for the remainder of this pipeline run (P1-P9, which dogfood the trimmed orchestrator and phase skills).
