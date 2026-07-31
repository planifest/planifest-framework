---
title: "Backlog Entry: 0000019 - Populate the regression pack"
summary: "tests/regression/ holds one test and a manifest against 29 top-level test scripts, so the safety net assumed by any cross-cutting refactor does not currently exist."
status: "open"
---
# Backlog Entry: 0000019 - Populate the regression pack

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-013 in the corrected recommendations; finding 5 in the corrected review

---

## Problem

`planifest-framework/tests/` holds 29 top-level test scripts. `planifest-framework/tests/regression/` holds exactly one test — `test-0000016-pipeline-governance.sh` — plus `regression-manifest.json`, despite `planifest-framework/scripts/promote-to-regression.sh` existing to populate it.

This matters most because it invalidates the mitigation normally proposed for risky framework refactors: "land it behind the regression suite". The promoted suite covers feature 0000016 alone. The 29 unpromoted scripts are per-feature tests — valuable, but not a safety net for a cross-cutting change to the entry-point skill.

The gap is promotion discipline, not test-writing discipline. The tests exist; nothing routes them into the pack.

## Suggested Action

Promote every test that asserts orchestrator routing, phase sequencing, hook enforcement or gate behaviour. Make promotion part of shipping rather than a discretionary afterthought: have the P9 ship phase prompt for promotion and record the promote-or-decline decision, with a reason, in the build log. Have `run-tests.sh` execute the regression pack as a distinct, separately reportable stage so its coverage is visible rather than inferred.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. Should be picked up **before** 0000020 — decomposing the orchestrator against a one-test pack is the scenario this entry exists to prevent.
