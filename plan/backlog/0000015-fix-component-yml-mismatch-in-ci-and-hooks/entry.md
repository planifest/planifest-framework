---
title: "Backlog Entry: 0000015 - Fix component.yml mismatch in CI and shipped hooks"
summary: "Four files match against component.json when the framework's manifest is component.yml, causing correct changes to be falsely rejected — including in the two hooks that setup.sh installs into every consuming repository."
status: "open"
---
# Backlog Entry: 0000015 - Fix component.yml mismatch in CI and shipped hooks

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-002 in the corrected recommendations; finding 4 in the corrected review

---

## Problem

The framework's component manifest is `component.yml`. Four files match against `component.json`.

**Live matchers — these gate merges and pushes:**

| File | Lines |
|---|---|
| `.github/workflows/planifest.yml` | 26, 37 |
| `planifest-framework/hooks/planifest.yml` | 26, 37 |
| `planifest-framework/hooks/pre-push` | 22, 38 |
| `planifest-framework/hooks/pre-commit` | 8 |

**Stale prose in comments and error strings:** `pre-push` lines 20, 25, 34, 37, 45; `pre-commit` line 11.

The shipped `hooks/` copies matter more than this repository's CI: `setup.sh` installs them into every consuming repository. The framework's own CI failing is an inconvenience; every adopter's pre-push hook failing is a defect in the product.

The defect is **over-strictness, not an enforcement hole**. The standard matcher is `^(plan/|docs/|.*component\.json)` — `plan/` and `docs/` still match, so nothing slips through. The failure mode is a false rejection: a change that touches `src/` and correctly updates its `component.yml`, without touching `plan/` or `docs/`, is blocked by an error message that names `component.yml` as the very remedy it just refused to accept. The fast-path branch, `(component\.json|plan/changelog/)`, fails the same way.

## Suggested Action

Replace every matcher and every human-readable string so both reference `component.yml`. Add two tests: one asserting that a change touching only `src/` plus a `component.yml`, with no `plan/` or `docs/` change, **passes** — this is the case currently broken — and one asserting that a `src/`-only change with no manifest, plan or docs update fails. Run both against the shipped `hooks/pre-push` and `hooks/pre-commit`, not only against the workflow.

Note for whoever picks this up: searching for this defect is itself error-prone. The workflow and hook matchers contain the escaped regex `component\.json`, so a fixed-string search for `component.json` misses them, while an unescaped pattern search misses the plain-text mentions in the hook comments. Verify with both forms.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. XS effort, and it touches the same file set as 0000016 — the two should be picked up together.
