---
title: "Backlog Entry: 0000008 - Implement ratchet marker same-changeset detection"
summary: "ratchet-check.mjs cannot verify who wrote .ratchet-approve; ADR-004's same-changeset detection was scoped but not implemented in 0.16.0 (P5 medium finding, REC-003)."
status: "open"
---
# Backlog Entry: 0000008 - Implement ratchet marker same-changeset detection

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** post-ship assessment
**Date filed:** 2026-07-11

---

## Problem

`ratchet-check.mjs` consumes any line in `plan/current/.ratchet-approve` matching the target path, but cannot verify the line was actually written by a human rather than by the agent it's meant to constrain. ADR-004 anticipated this ("same-changeset detection where detectable") but explicitly scoped it out of 0.16.0. P5's security report flagged this as a medium-severity residual finding: forgery is currently audit-detected (via `ratchet-log.md` + P8 reporting) rather than prevented. Recorded in `planifest-framework/component.yml` quirks and as REC-003 in the archived recommendations.

## Suggested Action

Reject marker consumption when the `.ratchet-approve` line was added in the same uncommitted change set as the guarded write (e.g. check `git diff --cached`/working-tree status for the marker file at consumption time; require the marker line to already be committed, or otherwise provably pre-existing, before it can be consumed).

## Why Deferred

Medium severity with an existing compensating control (audit trail); rollout-discipline principle applies — worth doing once the ratchet has real usage data on what "legitimate weakening" actually looks like in practice.
