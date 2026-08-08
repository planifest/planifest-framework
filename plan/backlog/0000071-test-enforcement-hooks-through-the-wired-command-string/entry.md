---
title: "Backlog Entry: 0000071 - Test enforcement hooks through the command string setup.sh actually writes"
summary: "A discovered-but-out-of-scope item deferred for pickup at a future P0."
status: "open"
---
# Backlog Entry: 0000071 - Test enforcement hooks through the command string setup.sh actually writes

**Source feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source phase:** P6
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`0000028`'s P5 found (SEC-001) that `setup.sh` had always wired every `hooks/enforcement/` hook into `.claude/settings.json` as a bare `.mjs` path with no interpreter, while 9 of the 10 hook sources are committed mode `100644` and `cp` propagates that mode. The wired command exited 126 and 7 enforcement hooks silently never ran, including that feature's own em dash guard and both telemetry backstops.

56 test suites did not catch it, for one reason: every test invokes hooks as `node <hook>.mjs`, the form that works, never through the command string the installer writes. The fix added assertions that the generated string contains a `node` prefix, plus a pattern guard against reintroducing a bare path. That is a real improvement but it checks the shape of the string rather than proving the string runs.

A future defect that is not a bare path reproduces the same silent failure: a wrong relative directory, a quoting error, or a missing interpreter on one branch only.

## Suggested Action

Add a test that parses the generated `settings.json`, takes an enforcement hook's `command` value verbatim, and executes it: assert exit 2 against a violating payload and exit 0 against a clean one. Do the same for at least one `UserPromptSubmit` entry. The point is that the string under test is the artifact the installer produced, not one the test built.

## Why Deferred

See `0000028`'s `recommendations.md` REC-001 and TD-005. The High finding itself was fixed inside `0000028`; what remains is closing the test-shape gap that let it hide, which is a testing-infrastructure change rather than part of the fix.
