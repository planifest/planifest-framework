---
title: "Backlog Entry: 0000001 - Flaky test suites: SIGPIPE under pipefail"
summary: "test-commit-msg-hook.sh and test-regression-pack.sh fail intermittently from the same pipefail/SIGPIPE pattern fixed in assert.sh during 0000016."
status: "open"
---
# Backlog Entry: 0000001 - Flaky test suites: SIGPIPE under pipefail

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** P3
**Date filed:** 2026-07-11

---

## Problem

`planifest-framework/tests/test-commit-msg-hook.sh` (3 fails: "73-char subject exits 1" reports actual 0; two empty-haystack assertions with `echo: write error: Broken pipe` at line 18) and `planifest-framework/tests/test-regression-pack.sh` (3 fails: empty haystacks from `promote-to-regression.sh` output capture) fail intermittently. Root-cause family identified during 0000016: under `set -uo pipefail`, piping into a consumer that exits early (e.g. `| tail -n1`, `grep -q`) makes the producer take SIGPIPE (exit 141) and pipefail fails the pipeline — the shared helper `tests/helpers/assert.sh` was fixed for exactly this in 0000016, but these two suites have their own local pipe patterns (`run_hook | tail -n1`, command-substitution captures) still exposed. The commit-msg hook itself works (verified live: it blocked a 73-char subject during the 0000016 run), so these are test-infrastructure defects, not product defects.

## Suggested Action

Rework the local capture patterns in both suites to avoid early-exit pipes under pipefail (e.g. capture output and exit code separately without piping to `tail`, mirroring the assert.sh builtin-substring fix).

## Why Deferred

Pre-existing, unrelated to 0000016's scope (files untouched since branch base); non-blocking because the failures are in test plumbing, not framework behaviour.
