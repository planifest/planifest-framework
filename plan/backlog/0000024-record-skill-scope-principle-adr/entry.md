---
title: "Backlog Entry: 0000024 - Record a skill-scope principle"
summary: "An ADR recording the test for whether a skill earns its place — governance the host tool cannot provide — with the four TDD-loop skills documented as worked examples of the retain verdict."
status: "open"
---
# Backlog Entry: 0000024 - Record a skill-scope principle

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-011 in the corrected recommendations; finding 8 in the corrected review

---

## Problem

The first-edition review proposed deprecating `planifest-implementer`, `planifest-test-writer`, `planifest-refactor` and `planifest-verify-by-execution` as duplicating host-tool behaviour. It proposed the right test — *does this provide governance or traceability the host tool cannot* — and then did not apply it.

Applied, the test **retains** them:

| Skill | Words | Verdict |
|---|---|---|
| `planifest-test-writer` | 586 | Retain. Enforces one failing test per requirement and RED confirmation by non-zero exit before implementation. Host tools permit test-first; they do not enforce it. |
| `planifest-implementer` | 557 | Retain. Enforces minimum-code-to-green with verified zero exit, gated on the prior RED. The constraint is the ordering. |
| `planifest-refactor` | 528 | Retain, marginal. Thinnest of the four; its governance content is close to host-tool default behaviour. |
| `planifest-verify-by-execution` | 481 | Retain. Encodes "do not accept test output as proof — run the software", which is the opposite of host-tool default. |

Together these are 2,152 words, seven per cent of the skills corpus. The maintenance-liability argument does not survive the sizes involved.

The durable point survives in weaker form: nothing currently stops the corpus accreting re-specifications of host behaviour as those tools improve.

## Suggested Action

Record an ADR capturing the governing test and its rationale, with the four assessments above as worked examples — including the marginal verdict on `planifest-refactor`. Reference the ADR from whatever process adds a new skill, so the test is applied at the point of addition rather than retrospectively.

If `planifest-refactor` is later dropped, it should be on the evidence of a build assessment showing it adds nothing, not on the duplication argument.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. Low severity and strategic rather than immediate — it governs future additions rather than fixing anything currently broken.
