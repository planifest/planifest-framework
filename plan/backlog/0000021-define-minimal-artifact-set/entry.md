---
title: "Backlog Entry: 0000021 - Define a minimal artifact set"
summary: "feature-pipeline.md mandates a cost model, SLO definitions and an operational model for every feature regardless of size; make the non-essential artifacts conditional on a declared trigger."
status: "open"
---
# Backlog Entry: 0000021 - Define a minimal artifact set

**Source feature:** N/A — independent framework review, corrected second edition (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31
**Reference:** `_reference/` — REQ-007 in the corrected recommendations; finding 2 in the corrected review

---

## Problem

`planifest-framework/workflows/feature-pipeline.md:25` mandates that Phase 1 produce "execution plan, OpenAPI spec (if applicable), scope, risk register, domain glossary, operational model, SLO definitions, cost model". Only the OpenAPI spec carries a condition.

A trivial feature therefore emits a cost model and a set of SLO definitions because the pipeline says so, not because anything about the feature warrants them.

The risk is not rigour. It is documentation theatre in which the artifacts become the deliverable and the reviewer stops reading — at which point the PR gate backstop fails silently, and the framework's central claim fails with it. This is the main barrier to adoption by anyone who is not the author.

## Suggested Action

Name a minimal set produced by default, and give every other artifact an explicit trigger condition — declared in the feature brief or inferred from a stated property of the feature. Reflect the conditional set in both `feature-pipeline.md:25` and the `planifest-spec-agent` skill, so the workflow and the agent agree. Have the orchestrator produce only the minimal set absent a trigger, and state the default artifact count for a typical feature in the README.

## Why Deferred

Filed from an external review rather than an in-flight pipeline feature. Needs a design decision about which artifacts are genuinely load-bearing, which is a judgement call for the human rather than something to infer from the templates.
