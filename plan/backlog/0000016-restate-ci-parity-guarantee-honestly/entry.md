---
title: "Backlog Entry: 0000016 - Restate CI parity guarantee honestly"
summary: "The parity check proves only that some file under plan/ or docs/ changed in the same PR, not that documentation corresponds to the code changed — the error messages and README describe it as stronger than it is."
status: "open"
---
# Backlog Entry: 0000016 - Restate CI parity guarantee honestly

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-003 in the corrected recommendations; finding 4 in the corrected review

---

## Problem

The standard parity check in `.github/workflows/planifest.yml:37` and its counterparts in `planifest-framework/hooks/pre-push:38` and `hooks/pre-commit:8` prove only that *some* file under `plan/` or `docs/` changed in the same pull request. They do not establish that the documentation corresponds to the code changed.

The failure messages describe it as stronger than it is — "Code modified without corresponding updates to plan/, docs/, or component.yml" implies a correspondence that is never checked. The README's Hard Limits section carries the same implication.

It is a smoke alarm, not a fire door. That is a reasonable thing to ship; describing it as a fire door is not.

## Suggested Action

Reword the CI failure message to state what was and was not checked, and apply the same rewording to the equivalent strings in `hooks/pre-push` and `hooks/pre-commit`. Align the README Hard Limits and Limitations sections with the same distinction — a presence heuristic, not a correspondence guarantee.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. XS effort. Touches the same files as 0000015 and should be picked up alongside it — both edit the hook strings.

## Related

An honest restatement here also serves 0000025 (adoption position): the Limitations section is the framework's strongest credibility asset and should be expanded, not softened.
