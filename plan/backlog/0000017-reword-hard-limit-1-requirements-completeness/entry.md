---
title: "Backlog Entry: 0000017 - Reword Hard Limit 1"
summary: "\"Requirements must be complete before codegen begins\" is unachievable in the strict sense and unfalsifiable as written; the framework's actual behaviour is better than the claim and should be what is stated."
status: "open"
---
# Backlog Entry: 0000017 - Reword Hard Limit 1

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-010 in the corrected recommendations; finding 7 in the corrected review

---

## Problem

`README.md:109` states Hard Limit 1 as "Requirements must be complete before codegen begins". Completeness in the strict sense is unachievable, and the claim is unfalsifiable as written — there is no observable state that would demonstrate it was violated.

The framework's actual behaviour is better than the slogan: gaps are surfaced during P0/P1, then either resolved or explicitly recorded as deferred, and the run proceeds. That is both defensible and checkable. Stating the stronger claim invites the fair criticism that the framework overpromises, and it does so in the section a sceptical reader scrutinises hardest.

## Suggested Action

Reword to describe the enforceable behaviour — gaps are surfaced and either resolved or explicitly recorded as deferred before code generation begins. Align the orchestrator's wording with the README's, and ensure the wording maps to an observable artifact in the plan folder so a reader can check the claim rather than take it on trust.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. XS effort and it edits the same README section as 0000014, so it is free to carry along in that fast-path run — which is why it sits earlier in the suggested order than its low severity alone would justify.
