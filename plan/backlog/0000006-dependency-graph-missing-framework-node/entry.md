---
title: "Backlog Entry: 0000006 - dependency-graph.md missing planifest-framework node"
summary: "docs/dependency-graph.md wasn't updated when planifest-framework was added to component-registry.md in 0000016 P6 — self-inflicted drift in the same run."
status: "open"
---
# Backlog Entry: 0000006 - dependency-graph.md missing planifest-framework node

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** post-ship assessment
**Date filed:** 2026-07-11

---

## Problem

`docs/component-registry.md` gained a new `planifest-framework` row during 0000016's P6 (docs-agent found it had never been registered as a component in its own registry). `docs/dependency-graph.md` was left unchanged in the same P6 pass — the build-log P6 note explicitly says "dependency graph unchanged (no component relationships changed)", but that reasoning didn't account for the registry gaining a node that the graph doesn't have. `docs/dependency-graph.md` is still last-updated `0000011-setup-parity-and-consistency` (17 May 2026) and its mermaid diagram + "Dependency Direction Notes" cover only `context-mode-hooks`; `planifest-framework` and `setup-hook-integration` (registered earlier) are both absent from the graph despite being in the registry.

## Suggested Action

Add `planifest-framework` (and audit whether `setup-hook-integration` is missing too) to `docs/dependency-graph.md`'s mermaid diagram and Dependency Direction Notes, bump its "Last updated" line, and treat "a component was added to the registry" as its own trigger for a dependency-graph update in the docs-agent's drift-check list going forward.

## Why Deferred

Docs-only, non-blocking; caught in post-ship review rather than mid-P6 to avoid re-opening an already-gated phase.
