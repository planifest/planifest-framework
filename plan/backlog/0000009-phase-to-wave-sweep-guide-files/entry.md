---
title: "Backlog Entry: 0000009 - Sweep remaining Phase-to-Wave wording in guide files"
summary: "REQ-006 renamed decomposition 'Phase' to 'Wave' in the brief template, orchestrator, and spec-agent; guide files (e.g. feature-brief-guide.md) may still carry the collision."
status: "open"
---
# Backlog Entry: 0000009 - Sweep remaining Phase-to-Wave wording in guide files

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** post-ship assessment
**Date filed:** 2026-07-11

---

## Problem

0000016's REQ-006 renamed the feature-decomposition grouping concept from "Phase" to "Wave" in `feature-brief.template.md`, the orchestrator's Decomposition section, and `planifest-spec-agent`'s "Phased Features" section, specifically to end the collision with the P0–P9 pipeline-phase terminology. The sweep was scoped to those three locations; guide files such as `templates/feature-brief-guide.md` and any docs prose that also uses "phase" in the decomposition sense were not audited and may still carry the same collision. Recorded as REC-005 in the archived recommendations.

## Suggested Action

Grep guide files and remaining docs prose for decomposition-sense "phase" (careful to exclude legitimate P0–P9 pipeline-phase references) and rename to "wave" for consistency with the now-renamed core artifacts.

## Why Deferred

Low priority, cosmetic terminology consistency — not blocking, but worth finishing what REQ-006 started before the two terms drift apart in documentation.
