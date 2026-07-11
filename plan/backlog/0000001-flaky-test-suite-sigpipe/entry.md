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

`planifest-framework/tests/test-regression-pack.sh` (3 fails) and `planifest-framework/tests/test-commit-msg-hook.sh` (3 fails) fail on macOS while passing in Linux CI. Two root causes diagnosed during 0000016's P4:

1. **GNU-ism `head -n -1`** (regression-pack lines 62/90/107, and the commit-msg block-output section): BSD/macOS `head` rejects negative line counts, so the captured `output` variable is empty — every `assert_contains` on it fails with an empty haystack.
2. **SIGPIPE under `set -uo pipefail`**: `run_hook | tail -n1`-style captures surface `echo: write error: Broken pipe` and can corrupt the captured exit code ("73-char subject exits 1" reporting actual 0). The shared helper `tests/helpers/assert.sh` was fixed for the same family in 0000016 (builtin substring instead of `printf | grep -q`), but these two suites have their own local pipe patterns still exposed.

The commit-msg hook itself works (verified live on macOS: it blocked a 73-char subject during the 0000016 run) — these are test-infrastructure portability defects, not product defects.

## Suggested Action

Replace `head -n -1` with a portable equivalent (e.g. `sed '$d'`) and rework the exit-code capture to avoid piping through `tail` under pipefail (capture output and `$?` into separate variables), in both suites.

## Why Deferred

Pre-existing, unrelated to 0000016's scope (files untouched since branch base); macOS-local only (Linux CI green); failures are in test plumbing, not framework behaviour.
