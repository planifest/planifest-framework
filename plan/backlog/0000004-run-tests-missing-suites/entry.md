---
title: "Backlog Entry: 0000004 - run-tests.sh does not register 5 of 14 suites"
summary: "The harness runner hardcodes 9 suites; test-0000007, test-0000010, test-0000016, test-commit-msg-hook, and test-skill-sync-security never run under it."
status: "open"
---
# Backlog Entry: 0000004 - run-tests.sh does not register 5 of 14 suites

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** P9 (post-ship review)
**Date filed:** 2026-07-11

---

## Problem

`planifest-framework/tests/run-tests.sh` hardcodes 9 `run_suite` lines. Five existing suites are never executed by it: `test-0000007-agent-optimisation.sh`, `test-0000010-framework-quality-improvements.sh`, `test-0000016-pipeline-governance.sh` (this feature's own suite — a 0000016 gap: it was written and run directly at P3/P4 but never registered), `test-commit-msg-hook.sh`, and `test-skill-sync-security.sh`. The runner's "7 passed, 2 failed" therefore understates the real state (individually: 9 pass, 5 fail — see backlog 0000001 and 0000003 for the failures). Each new feature must currently remember to add a line, and 0000016 (at least) forgot.

## Suggested Action

Replace the hardcoded list with a glob over `tests/test-*.sh` (excluding `test_setup.sh` and helper-sourced files), or at minimum register the five missing suites. Add a self-check that fails the runner when an unregistered `test-*.sh` exists.

## Why Deferred

Registering the missing suites makes the runner honestly red until backlog 0000001/0000003 land — sequence the three entries together in one cleanup feature.
