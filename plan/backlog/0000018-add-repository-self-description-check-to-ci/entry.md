---
title: "Backlog Entry: 0000018 - Add a repository self-description check to CI"
summary: "README drift will recur without automation; add a new repository-scoped CI script that verifies the structure diagram's paths exist and every framework folder has a table row."
status: "open"
---
# Backlog Entry: 0000018 - Add a repository self-description check to CI

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-004 in the corrected recommendations

---

## Problem

The drift catalogued in 0000014 will recur without automation. The project's credibility depends on its self-description being accurate, and nothing currently checks it.

## Suggested Action

Add a **new repository-scoped script** that verifies every path named in the README structure diagram exists, and that every folder in `planifest-framework/` has a corresponding row in the framework table. Run it on pull request; failure should name the divergent path or row.

**Do not extend `planifest-framework/scripts/consistency-check.mjs`.** That script validates `plan/current/` during a feature run — story traceability, acceptance-criteria counts, ADR resolution, risk mitigations, design scope — and is invoked by the `planifest-design-critic` skill with exit-code semantics tied to that role. README-versus-filesystem accuracy is a repository invariant on a different lifecycle, checked in CI regardless of whether a feature is in flight. Combining them couples a per-feature gate to repository metadata and makes `consistency-check.mjs` fail in contexts where it has nothing to say.

Scope note: if 0000014 removes the Count column as suggested, this check verifies existence and coverage only. It counts nothing, which is what keeps it stable.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. Depends on 0000014 landing first — the check should encode the corrected structure, not the current one.
